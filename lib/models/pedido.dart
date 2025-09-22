class Pedido {
  final String id;
  final String cliente;
  final String descricao;
  final double valor;  // valor total do pedido
  final double? tecido; // gasto com tecido (opcional)
  final double? tempo;  // custo de mão de obra (opcional)

  Pedido({
    required this.id,
    required this.cliente,
    required this.descricao,
    required this.valor,
    this.tecido,
    this.tempo,
  });
}
