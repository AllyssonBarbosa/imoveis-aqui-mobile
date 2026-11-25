import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/periodo_contatos.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../../domain/usecases/obter_acervo_por_corretor_usecase.dart';
import '../../domain/usecases/obter_contatos_por_corretor_usecase.dart';
import '../../domain/usecases/obter_mudancas_recentes_usecase.dart';
import '../../domain/usecases/obter_totais_por_situacao_usecase.dart';
import 'area_gestor_state.dart';

/// Orquestra a Área do gestor (GES-01..GES-06). Não conta, não soma e não
/// filtra nada (critério 5): o estado só recebe as entidades que os use cases
/// devolvem.
///
/// Cada seção é um pedido independente com a própria versão (D-07):
/// `_versaoTotais`, `_versaoAcervo`, `_versaoContatos` e `_versaoMudancas`
/// descartam uma resposta que já foi superada por um pedido mais novo da mesma
/// seção (o período trocado, dois "Tentar de novo" seguidos). Decide só pelo
/// TIPO da falha (D-22, D-23): `SessaoExpiradaException` vira `sessaoExpirada`
/// (terminal), `SemPermissaoException` vira [FalhaDaSecao.semPermissao] e o
/// resto, [FalhaDaSecao.indisponivel] (D-24). [isClosed] é conferido antes de
/// todo `emit`.
@injectable
class AreaGestorCubit extends Cubit<AreaGestorState> {
  AreaGestorCubit(
    this._obterTotais,
    this._obterAcervo,
    this._obterContatos,
    this._obterMudancas,
  ) : super(const AreaGestorState());

  final ObterTotaisPorSituacaoUseCase _obterTotais;
  final ObterAcervoPorCorretorUseCase _obterAcervo;
  final ObterContatosPorCorretorUseCase _obterContatos;
  final ObterMudancasRecentesUseCase _obterMudancas;

  int _versaoTotais = 0;
  int _versaoAcervo = 0;
  int _versaoContatos = 0;
  int _versaoMudancas = 0;

  /// `true` quando nada mais deve ser pedido nem emitido: o Cubit fechou ou a
  /// sessão terminou (D-22).
  bool get _encerrado => isClosed || state.sessaoExpirada;

  /// Ponto de entrada — chamado ao abrir a tela: pede os 4 relatórios em
  /// paralelo, o de contatos com o período atual (nulo = todo o período).
  void carregar() {
    unawaited(_carregarTotais());
    unawaited(_carregarAcervo());
    unawaited(_carregarContatos(state.periodo));
    unawaited(_carregarMudancas());
  }

  /// "Tentar de novo" de uma seção: repete só o pedido dela (D-07).
  Future<void> tentarNovamente(SecaoDaAreaGestor secao) => switch (secao) {
    SecaoDaAreaGestor.totais => _carregarTotais(),
    SecaoDaAreaGestor.acervo => _carregarAcervo(),
    SecaoDaAreaGestor.contatos => _carregarContatos(state.periodo),
    SecaoDaAreaGestor.mudancas => _carregarMudancas(),
  };

  /// Aplica [periodo] à seção de contatos e recarrega só ela (D-16). Sem efeito
  /// se já é o período aplicado.
  Future<void> aplicarPeriodo(PeriodoContatos periodo) async {
    if (_encerrado) return;
    if (state.periodo == periodo) return;
    await _carregarContatos(periodo);
  }

  /// Volta ao "todo o período" e recarrega só os contatos (D-16). Sem efeito
  /// se já não há período.
  Future<void> limparPeriodo() async {
    if (_encerrado) return;
    if (state.periodo == null) return;
    await _carregarContatos(null);
  }

  Future<void> _carregarTotais() async {
    if (_encerrado) return;
    final versao = ++_versaoTotais;
    emit(state.copyWith(totais: const EstadoSecao.carregando()));

    final resultado = await _obterTotais();

    if (_encerrado || versao != _versaoTotais) return;
    final secao = _traduzir(resultado);
    if (secao == null) {
      emit(state.copyWith(sessaoExpirada: true));
    } else {
      emit(state.copyWith(totais: secao));
    }
  }

  Future<void> _carregarAcervo() async {
    if (_encerrado) return;
    final versao = ++_versaoAcervo;
    emit(state.copyWith(acervo: const EstadoSecao.carregando()));

    final resultado = await _obterAcervo();

    if (_encerrado || versao != _versaoAcervo) return;
    final secao = _traduzir(resultado);
    if (secao == null) {
      emit(state.copyWith(sessaoExpirada: true));
    } else {
      emit(state.copyWith(acervo: secao));
    }
  }

  Future<void> _carregarContatos(PeriodoContatos? periodo) async {
    if (_encerrado) return;
    final versao = ++_versaoContatos;
    emit(
      state.copyWith(
        periodo: periodo,
        contatos: const EstadoSecao.carregando(),
      ),
    );

    final resultado = await _obterContatos(periodo);

    if (_encerrado || versao != _versaoContatos) return;
    final secao = _traduzir(resultado);
    if (secao == null) {
      emit(state.copyWith(sessaoExpirada: true));
    } else {
      emit(state.copyWith(contatos: secao));
    }
  }

  Future<void> _carregarMudancas() async {
    if (_encerrado) return;
    final versao = ++_versaoMudancas;
    emit(state.copyWith(mudancas: const EstadoSecao.carregando()));

    final resultado = await _obterMudancas();

    if (_encerrado || versao != _versaoMudancas) return;
    final secao = _traduzir(resultado);
    if (secao == null) {
      emit(state.copyWith(sessaoExpirada: true));
    } else {
      emit(state.copyWith(mudancas: secao));
    }
  }

  /// Traduz o [Result] de um use case no estado da seção, só pelo TIPO da
  /// falha; `null` quando é o 401 — o chamador encerra a sessão (D-22).
  EstadoSecao<T>? _traduzir<T>(Result<T> resultado) => switch (resultado) {
    Success(:final data) => EstadoSecao<T>.carregada(data),
    Failure(:final erro) => switch (erro) {
      SessaoExpiradaException() => null,
      SemPermissaoException() => EstadoSecao<T>.comFalha(
        FalhaDaSecao.semPermissao,
      ),
      _ => EstadoSecao<T>.comFalha(FalhaDaSecao.indisponivel),
    },
    // Os use cases só devolvem `Success` ou `Failure`; a seção segue em voo.
    Loading() => EstadoSecao<T>.carregando(),
  };
}
