import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/dados_natureza.dart';
import '../vitrine/apresentacao_imovel.dart';

/// Funções puras de apresentação dos dados da natureza (DET-04, D-13) — quais
/// linhas existem é decidido aqui, nunca espalhado em widgets. Só formatam o
/// que o servidor mandou: nenhuma soma, diferença ou total de áreas (D-04) e
/// nenhum preço derivado (D-19 d).

/// Um item da linha de destaques: ícone, valor em evidência e rótulo curto.
typedef Destaque = ({IconData icone, String valor, String rotulo});

/// Uma linha rótulo/valor da ficha da natureza.
typedef LinhaDado = ({String rotulo, String valor});

final NumberFormat _formatoDecimal = NumberFormat('#,##0.##', 'pt_BR');

/// "180.00" -> "180 m²", "68.50" -> "68,5 m²". Um valor não-parseável é
/// devolvido sem alteração — nunca lança (Pitfall 7).
String formatarAreaM2(String valorDecimal) {
  final valor = double.tryParse(valorDecimal);
  if (valor == null) return valorDecimal;
  return '${_formatoDecimal.format(valor)} m²';
}

/// "12.00" -> "12 m", "10.50" -> "10,5 m". Um valor não-parseável é devolvido
/// sem alteração — nunca lança.
String formatarMedidaM(String valorDecimal) {
  final valor = double.tryParse(valorDecimal);
  if (valor == null) return valorDecimal;
  return '${_formatoDecimal.format(valor)} m';
}

String rotuloTopografia(Topografia topografia) {
  return switch (topografia) {
    Topografia.plano => 'Plano',
    Topografia.aclive => 'Aclive',
    Topografia.declive => 'Declive',
  };
}

String rotuloSimNao(bool valor) => valor ? 'Sim' : 'Não';

/// Título da seção de natureza: "Sobre a casa", "Sobre o apartamento"...
String tituloSecaoNatureza(DadosNatureza dados) {
  return switch (dados) {
    DadosCasa() => 'Sobre a casa',
    DadosApartamento() => 'Sobre o apartamento',
    DadosTerreno() => 'Sobre o terreno',
    DadosLote() => 'Sobre o lote',
  };
}

/// Linha de destaques com ícone (D-13). Contagem nula ou zero é omitida, como
/// no card da vitrine; medidas nulas também.
List<Destaque> destaquesDe(DadosNatureza dados) {
  return switch (dados) {
    DadosCasa(:final quartos, :final suites, :final banheiros, :final vagas) =>
      _destaquesDeComodos(
        quartos: quartos,
        suites: suites,
        banheiros: banheiros,
        vagas: vagas,
      ),
    DadosApartamento(
      :final quartos,
      :final suites,
      :final banheiros,
      :final vagas,
    ) =>
      _destaquesDeComodos(
        quartos: quartos,
        suites: suites,
        banheiros: banheiros,
        vagas: vagas,
      ),
    DadosTerreno(:final areaTotal, :final frente, :final fundo) =>
      _destaquesDeMedidas(area: areaTotal, frente: frente, fundo: fundo),
    DadosLote(:final area, :final frente, :final fundo) => _destaquesDeMedidas(
      area: area,
      frente: frente,
      fundo: fundo,
    ),
  };
}

/// Linhas rótulo/valor da natureza, na ordem de exibição; campo nulo não gera
/// linha (D-14).
List<LinhaDado> linhasDe(DadosNatureza dados) {
  return switch (dados) {
    final DadosCasa casa => [
      ..._area('Área do terreno', casa.areaTerreno),
      ..._area('Área construída', casa.areaConstruida),
      ..._area('Área livre', casa.areaLivre),
      ..._inteiro('Salas', casa.salas),
      ..._inteiro('Pavimentos', casa.pavimentos),
      ..._inteiro('Ano de construção', casa.anoConstrucao),
      ..._simNao('Piscina', casa.piscina),
      ..._simNao('Quintal', casa.quintal),
      ..._simNao('Churrasqueira', casa.churrasqueira),
      ..._simNao('Mobiliada', casa.mobiliada),
    ],
    final DadosApartamento apartamento => [
      if (apartamento.andar case final andar?)
        (rotulo: 'Andar', valor: '$andarº'),
      ..._texto('Unidade', apartamento.numero),
      ..._area('Área privativa', apartamento.areaPrivativa),
      ..._area('Área total', apartamento.areaTotal),
      ..._simNao('Varanda', apartamento.varanda),
      // Texto da API como veio: o app não tem enum nem tabela de rótulos
      // para a posição solar (D-19 b).
      ..._texto('Posição solar', apartamento.posicaoSolar),
    ],
    final DadosTerreno terreno => [
      ..._medida('Laterais', terreno.laterais),
      if (terreno.topografia case final topografia?)
        (rotulo: 'Topografia', valor: rotuloTopografia(topografia)),
      ..._simNao('Murado', terreno.murado),
      ..._simNao('Esquina', terreno.esquina),
      ..._texto('Uso permitido', terreno.usoPermitido),
    ],
    final DadosLote lote => [
      ..._texto('Número do lote', lote.numero),
      // Só quando o servidor manda `preco`; nunca derivado de preco_venda /
      // preco_aluguel, que o cabeçalho já mostra (D-19 d).
      if (lote.preco case final preco?)
        (rotulo: 'Preço do lote', valor: formatarPrecoBrl(preco)),
      ..._texto('Condições de parcelamento', lote.condicoesParcelamento),
    ],
  };
}

/// Linhas do card do prédio do apartamento, na ordem de exibição; campo nulo
/// não gera linha (D-14).
List<LinhaDado> linhasDoPredio(DadosPredio predio) {
  return [
    ..._texto('Nome', predio.nome),
    ..._inteiro('Andares', predio.andares),
    ..._inteiro('Unidades por andar', predio.unidadesPorAndar),
    ..._inteiro('Ano', predio.ano),
    ..._inteiro('Elevadores', predio.elevadores),
    ..._simNao('Portaria 24h', predio.portaria24h),
    ..._simNao('Piscina', predio.piscina),
    ..._simNao('Academia', predio.academia),
    ..._simNao('Salão de festas', predio.salaoDeFestas),
    ..._simNao('Playground', predio.playground),
  ];
}

/// Linhas do card da quadra e do loteamento do lote; as listas de
/// infraestrutura e áreas de lazer são desenhadas à parte, como `Chip`s.
List<LinhaDado> linhasDaQuadra(DadosQuadra quadra) {
  return [
    ..._texto('Quadra', quadra.identificacao),
    ..._texto('Loteamento', quadra.loteamento?.nome),
    ..._texto('Incorporadora', quadra.loteamento?.incorporadora),
  ];
}

/// `true` quando o card da quadra e do loteamento tem algo para mostrar:
/// alguma linha ou alguma das duas listas (D-14).
bool quadraTemConteudo(DadosQuadra quadra) {
  final loteamento = quadra.loteamento;
  return linhasDaQuadra(quadra).isNotEmpty ||
      (loteamento != null &&
          (loteamento.infraestrutura.isNotEmpty ||
              loteamento.areasLazer.isNotEmpty));
}

List<Destaque> _destaquesDeComodos({
  required int? quartos,
  required int? suites,
  required int? banheiros,
  required int? vagas,
}) {
  return [
    ..._contagem(Icons.bed_outlined, quartos, 'quarto', 'quartos'),
    ..._contagem(Icons.king_bed_outlined, suites, 'suíte', 'suítes'),
    ..._contagem(Icons.bathtub_outlined, banheiros, 'banheiro', 'banheiros'),
    ..._contagem(Icons.directions_car_outlined, vagas, 'vaga', 'vagas'),
  ];
}

List<Destaque> _destaquesDeMedidas({
  required String? area,
  required String? frente,
  required String? fundo,
}) {
  return [
    if (area != null)
      (icone: Icons.square_foot, valor: formatarAreaM2(area), rotulo: 'área'),
    if (frente != null)
      (
        icone: Icons.straighten,
        valor: formatarMedidaM(frente),
        rotulo: 'frente',
      ),
    if (fundo != null)
      (icone: Icons.straighten, valor: formatarMedidaM(fundo), rotulo: 'fundo'),
  ];
}

List<Destaque> _contagem(
  IconData icone,
  int? quantidade,
  String singular,
  String plural,
) {
  if (quantidade == null || quantidade == 0) return const [];
  return [
    (
      icone: icone,
      valor: '$quantidade',
      rotulo: quantidade == 1 ? singular : plural,
    ),
  ];
}

List<LinhaDado> _texto(String rotulo, String? valor) {
  if (valor == null) return const [];
  return [(rotulo: rotulo, valor: valor)];
}

List<LinhaDado> _inteiro(String rotulo, int? valor) {
  if (valor == null) return const [];
  return [(rotulo: rotulo, valor: '$valor')];
}

List<LinhaDado> _area(String rotulo, String? valor) {
  if (valor == null) return const [];
  return [(rotulo: rotulo, valor: formatarAreaM2(valor))];
}

List<LinhaDado> _medida(String rotulo, String? valor) {
  if (valor == null) return const [];
  return [(rotulo: rotulo, valor: formatarMedidaM(valor))];
}

List<LinhaDado> _simNao(String rotulo, bool? valor) {
  if (valor == null) return const [];
  return [(rotulo: rotulo, valor: rotuloSimNao(valor))];
}
