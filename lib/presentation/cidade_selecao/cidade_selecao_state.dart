import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/cidade.dart';

part 'cidade_selecao_state.freezed.dart';

/// União selada com todo desfecho alcançável do fluxo de localização/escolha
/// de cidade (D-07) — nunca uma exceção genérica para um desfecho esperado
/// do domínio (LOC-06).
///
/// `localizando` é o estado transiente enquanto GPS+geocodificação resolvem;
/// `erroCarregarCidades` é o estado defensivo de falha ao carregar/parsear o
/// asset de cidades (UI-SPEC E2/E3 error) — nenhum dos dois é, em si, um dos
/// "5 desfechos de localização" de LOC-06, mas ambos precisam de UI própria
/// (LOC-06/D-07), então integram a mesma união selada.
@freezed
sealed class CidadeSelecaoState with _$CidadeSelecaoState {
  /// Enquanto GPS + reverse geocoding resolvem.
  const factory CidadeSelecaoState.localizando() = Localizando;

  /// Autorizada + cidade detectada ESTÁ na lista atendida (D-10) — entra
  /// direto, sem passo de confirmação. Também usado para o desfecho de
  /// cidade já salva (D-08) e para a seleção manual na lista (D-10 aplicado
  /// por analogia).
  const factory CidadeSelecaoState.autorizadaEAtendida(Cidade cidade) =
      AutorizadaEAtendida;

  /// Autorizada + cidade detectada NÃO está na lista atendida (D-11).
  const factory CidadeSelecaoState.autorizadaNaoAtendida(
    String cidadeDetectada,
    List<Cidade> cidadesAtendidas,
  ) = AutorizadaNaoAtendida;

  /// Permissão recusada — caminho normal, cai na lista (LOC-03).
  const factory CidadeSelecaoState.recusada(List<Cidade> cidadesAtendidas) =
      Recusada;

  /// Permissão bloqueada para sempre (D-06) — cai na lista + CTA para abrir
  /// as configurações do sistema.
  const factory CidadeSelecaoState.bloqueadaParaSempre(
    List<Cidade> cidadesAtendidas,
  ) = BloqueadaParaSempre;

  /// Serviço de localização do aparelho desligado.
  const factory CidadeSelecaoState.servicoDesligado(
    List<Cidade> cidadesAtendidas,
  ) = ServicoDesligado;

  /// Falha no reverse geocoding — sem internet, timeout, sem resultado, ou
  /// `MissingPluginException`/`UnimplementedError` em plataforma sem suporte
  /// (D-12, Pitfall 1/A1). Mais um desfecho explícito, nunca tela de erro.
  const factory CidadeSelecaoState.falhaGeocodificacao(
    List<Cidade> cidadesAtendidas,
  ) = FalhaGeocodificacao;

  /// Falha ao carregar/parsear o asset de cidades — estado defensivo,
  /// nunca uma tela fatal (UI-SPEC E2/E3 error).
  const factory CidadeSelecaoState.erroCarregarCidades() = ErroCarregarCidades;
}
