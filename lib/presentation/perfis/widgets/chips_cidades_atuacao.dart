import 'package:flutter/material.dart';

import '../../../domain/entities/cidade.dart';
import '../../detalhe_imovel/widgets/secoes_detalhe.dart';

/// Seção "Cidades de atuação" da página da empresa: um `Chip` "Cidade, UF" por
/// cidade, na ordem recebida da API, em linhas que quebram. Some por inteiro
/// quando a empresa não informa cidades.
class ChipsCidadesAtuacao extends StatelessWidget {
  const ChipsCidadesAtuacao({super.key, required this.cidades});

  final List<Cidade> cidades;

  @override
  Widget build(BuildContext context) {
    if (cidades.isEmpty) return const SizedBox.shrink();
    return SecaoDetalhe(
      titulo: 'Cidades de atuação',
      conteudo: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final cidade in cidades)
            Chip(label: Text('${cidade.nome}, ${cidade.uf}')),
        ],
      ),
    );
  }
}
