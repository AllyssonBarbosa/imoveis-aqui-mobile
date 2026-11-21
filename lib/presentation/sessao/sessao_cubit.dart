import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/ler_sessao_usecase.dart';
import '../../domain/usecases/sair_usecase.dart';
import 'sessao_state.dart';

/// Dono único da sessão no app, singleton provido acima do `MaterialApp` para
/// todas as rotas empurradas enxergarem a mesma sessão.
///
/// Só lê o aparelho, nunca a rede (AC-6): a vitrine não espera o servidor para
/// decidir o rótulo do topo. O papel é perguntado ao servidor só ao entrar ou
/// ao tocar em "Meu acervo".
@lazySingleton
class SessaoCubit extends Cubit<SessaoState> {
  SessaoCubit(this._lerSessao, this._sair)
    : super(const SessaoState.verificando());

  final LerSessaoUseCase _lerSessao;
  final SairUseCase _sair;

  /// Lê o aparelho e decide entre anônima e autenticada.
  Future<void> carregar() async {
    final temSessao = await _lerSessao();
    if (isClosed) return;
    emit(
      temSessao
          ? const SessaoState.autenticada()
          : const SessaoState.anonima(),
    );
  }

  /// Chamado pelo login depois de entrar com sucesso.
  void marcarAutenticada() {
    if (isClosed) return;
    emit(const SessaoState.autenticada());
  }

  /// Chamado quando a sessão deixa de valer (token recusado).
  void marcarAnonima() {
    if (isClosed) return;
    emit(const SessaoState.anonima());
  }

  /// Encerra a sessão e termina sempre anônimo (AC-2).
  ///
  /// Sem `catch`: a camada de dados garante que [SairUseCase] não lança. O
  /// `finally` só mantém o estado anônimo se esse contrato um dia quebrar, e
  /// emite depois do descarte do token para um novo login não correr com um
  /// `apagar()` pendente.
  Future<void> sair() async {
    try {
      await _sair();
    } finally {
      if (!isClosed) emit(const SessaoState.anonima());
    }
  }
}
