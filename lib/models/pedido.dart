import 'insumo.dart';

enum PedidoStatus { emAndamento, entregue, pago }

class Pedido {
  final String id;
  final String cliente;
  final String descricao;
  final double valor;  // valor total do pedido (total)
  final double? tecido; // gasto com tecido (opcional)
  final double? tempo;  // custo de mão de obra (legado)
  final double? gastosExtras; // novos gastos extras
  final double? maoDeObra;   // alias moderno para tempo
  final double? desconto;    // descontos aplicados

  // Novos campos para cálculo detalhado
  final List<Insumo> itensInsumo;
  final double? tempoHoras;
  final double? valorHora; // padrão sugerido: 30.0
  final double? custoOperacional; // valor agregado por pedido
  final double? margemLucroPercent; // padrão sugerido: 30.0
  final PedidoStatus? status;
  final DateTime? dataCriacao;
  final DateTime? dataEntregaPrevista;
  final DateTime? dataEntregaReal;
  final DateTime? dataPagamento;
  final double? precoSugerido; // calculado
  final double? precoFinal; // pode sobrescrever o sugerido

  Pedido({
    required this.id,
    required this.cliente,
    required this.descricao,
    required this.valor,
    this.tecido,
    this.tempo,
    this.gastosExtras,
    this.maoDeObra,
    this.desconto,
    this.itensInsumo = const [],
    this.tempoHoras,
    this.valorHora,
    this.custoOperacional,
    this.margemLucroPercent,
    this.status,
    this.dataCriacao,
    this.dataEntregaPrevista,
    this.dataEntregaReal,
    this.dataPagamento,
    this.precoSugerido,
    this.precoFinal,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'cliente': cliente,
        'descricao': descricao,
        'valor': valor,
        'tecido': tecido,
        'tempo': tempo,
        'gastosExtras': gastosExtras,
        'maoDeObra': maoDeObra,
        'desconto': desconto,
        'itensInsumo': itensInsumo.map((e) => e.toMap()).toList(),
        'tempoHoras': tempoHoras,
        'valorHora': valorHora,
        'custoOperacional': custoOperacional,
        'margemLucroPercent': margemLucroPercent,
        'status': status?.index,
        'dataCriacao': dataCriacao?.millisecondsSinceEpoch,
        'dataEntregaPrevista': dataEntregaPrevista?.millisecondsSinceEpoch,
        'dataEntregaReal': dataEntregaReal?.millisecondsSinceEpoch,
        'dataPagamento': dataPagamento?.millisecondsSinceEpoch,
        'precoSugerido': precoSugerido,
        'precoFinal': precoFinal,
      };

  factory Pedido.fromMap(Map map) => Pedido(
        id: (map['id'] ?? '') as String,
        cliente: (map['cliente'] ?? '') as String,
        descricao: (map['descricao'] ?? '') as String,
        valor: (map['valor'] ?? 0).toDouble(),
        tecido: map['tecido'] == null ? null : (map['tecido']).toDouble(),
        tempo: map['tempo'] == null ? null : (map['tempo']).toDouble(),
        gastosExtras: map['gastosExtras'] == null ? null : (map['gastosExtras']).toDouble(),
        maoDeObra: map['maoDeObra'] == null
            ? (map['tempo'] == null ? null : (map['tempo']).toDouble())
            : (map['maoDeObra']).toDouble(),
        desconto: map['desconto'] == null ? null : (map['desconto']).toDouble(),
        itensInsumo: ((map['itensInsumo'] ?? []) as List)
            .map((e) => Insumo.fromMap(e as Map))
            .toList(),
        tempoHoras:
            map['tempoHoras'] == null ? null : (map['tempoHoras']).toDouble(),
        valorHora: map['valorHora'] == null ? null : (map['valorHora']).toDouble(),
        custoOperacional: map['custoOperacional'] == null
            ? null
            : (map['custoOperacional']).toDouble(),
        margemLucroPercent: map['margemLucroPercent'] == null
            ? null
            : (map['margemLucroPercent']).toDouble(),
        status: map['status'] == null
            ? null
            : PedidoStatus.values[(map['status'] as num).toInt()],
        dataCriacao: map['dataCriacao'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                (map['dataCriacao'] as num).toInt()),
        dataEntregaPrevista: map['dataEntregaPrevista'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                (map['dataEntregaPrevista'] as num).toInt()),
        dataEntregaReal: map['dataEntregaReal'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                (map['dataEntregaReal'] as num).toInt()),
        dataPagamento: map['dataPagamento'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                (map['dataPagamento'] as num).toInt()),
        precoSugerido: map['precoSugerido'] == null
            ? null
            : (map['precoSugerido']).toDouble(),
        precoFinal:
            map['precoFinal'] == null ? null : (map['precoFinal']).toDouble(),
      );
}
