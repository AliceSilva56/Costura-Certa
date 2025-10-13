class Insumo {
  final String nome;
  final String tipo; // tecido, linha, aviamento, etc.
  final String unidade; // m, m2, un, etc.
  final double quantidade;
  final double custoUnitario;

  const Insumo({
    required this.nome,
    required this.tipo,
    required this.unidade,
    required this.quantidade,
    required this.custoUnitario,
  });

  double get custoTotal => quantidade * custoUnitario;

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'tipo': tipo,
        'unidade': unidade,
        'quantidade': quantidade,
        'custoUnitario': custoUnitario,
      };

  factory Insumo.fromMap(Map map) => Insumo(
        nome: (map['nome'] ?? '') as String,
        tipo: (map['tipo'] ?? '') as String,
        unidade: (map['unidade'] ?? '') as String,
        quantidade: (map['quantidade'] ?? 0).toDouble(),
        custoUnitario: (map['custoUnitario'] ?? 0).toDouble(),
      );
}
