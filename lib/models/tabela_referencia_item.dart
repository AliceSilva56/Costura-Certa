enum ReferenciaTipo { conserto, pecaDoZero }

class TabelaReferenciaItem {
  final ReferenciaTipo tipo;
  final String titulo;
  final String descricao;
  final double precoMedioMin;
  final double precoMedioMax;
  final Map<String, dynamic>? preset; // ex.: { tempoHoras: 1.0, insumos: [...] }
  final String? observacao; // avisos: valores de referência, região etc.

  const TabelaReferenciaItem({
    required this.tipo,
    required this.titulo,
    required this.descricao,
    required this.precoMedioMin,
    required this.precoMedioMax,
    this.preset,
    this.observacao,
  });
}
