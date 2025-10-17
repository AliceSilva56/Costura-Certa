import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/pedido.dart';
import '../services/pedidos_provider.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  PedidoStatus? _statusFilter; // null = todos
  bool _paidOnly = false;

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = Provider.of<PedidosProvider>(context);

    final pedidosFiltrados = pedidosProvider.pedidos.where((p) {
      final statusOk = _statusFilter == null || (p.status ?? PedidoStatus.emAndamento) == _statusFilter;
      final pagoOk = !_paidOnly || p.dataPagamento != null;
      return statusOk && pagoOk;
    }).toList();

    return Scaffold(
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<PedidoStatus?>(
                    value: _statusFilter,
                    decoration: const InputDecoration(labelText: 'Status', isDense: true),
                    items: const [
                      DropdownMenuItem<PedidoStatus?>(value: null, child: Text('Todos')),
                      DropdownMenuItem<PedidoStatus?>(value: PedidoStatus.emAndamento, child: Text('Em andamento')),
                      DropdownMenuItem<PedidoStatus?>(value: PedidoStatus.entregue, child: Text('Concluído')),
                    ],
                    onChanged: (v) => setState(() => _statusFilter = v),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Pagos'),
                    const SizedBox(width: 6),
                    Switch(
                      value: _paidOnly,
                      onChanged: (v) => setState(() => _paidOnly = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: pedidosFiltrados.length,
              itemBuilder: (context, index) {
                final pedido = pedidosFiltrados[index];
          final custos = (pedido.tecido ?? 0) + (pedido.gastosExtras ?? 0);
          final lucro = (pedido.valor) - custos;
          final status = pedido.status ?? PedidoStatus.emAndamento;
          final color = status == PedidoStatus.emAndamento
              ? Colors.amber
              : Colors.green;
          final pago = pedido.dataPagamento != null;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(
                status == PedidoStatus.emAndamento
                    ? Icons.timelapse
                    : Icons.check_circle,
                color: color,
              ),
            ),
            title: Text(pedido.cliente),
            subtitle: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(text: '${pedido.descricao} • ${status == PedidoStatus.entregue ? 'Concluído' : 'Em andamento'} • '),
                  TextSpan(
                    text: pago ? 'Pago' : 'Não pago',
                    style: TextStyle(
                      color: pago ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' • Lucro: R\$ ${lucro.toStringAsFixed(2)}'),
                ],
              ),
            ),
            trailing: Text("R\$ ${pedido.valor.toStringAsFixed(2)}"),
            onTap: () => Navigator.pushNamed(context, '/detalhes', arguments: pedido),
            onLongPress: () => _mostrarOpcoes(context, pedido),
          );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarFormulario(BuildContext context, {Pedido? pedidoExistente}) {
    final clienteController = TextEditingController(text: pedidoExistente?.cliente ?? "");
    final descricaoController = TextEditingController(text: pedidoExistente?.descricao ?? "");
    final tecidoController = TextEditingController(text: (pedidoExistente?.tecido ?? 0).toString());
    final gastosExtrasController = TextEditingController(text: (pedidoExistente?.gastosExtras ?? 0).toString());
    final maoDeObraController = TextEditingController(text: (pedidoExistente?.maoDeObra ?? 0).toString());
    final descontoController = TextEditingController(text: (pedidoExistente?.desconto ?? 0).toString());
    PedidoStatus status = pedidoExistente?.status ?? PedidoStatus.emAndamento;
    bool pago = (pedidoExistente?.dataPagamento != null);

    double parse(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          void recomputeIfEmptyMaoDeObra() {
            final tecido = parse(tecidoController);
            final extras = parse(gastosExtrasController);
            final suggested = (tecido + extras) * 0.5;
            if ((pedidoExistente == null && (maoDeObraController.text.isEmpty || parse(maoDeObraController) == 0))) {
              maoDeObraController.text = suggested.toStringAsFixed(2);
            }
          }

          void onChanged(_) => setState(() {});

          recomputeIfEmptyMaoDeObra();

          final tecido = parse(tecidoController);
          final extras = parse(gastosExtrasController);
          final mao = parse(maoDeObraController);
          final desc = parse(descontoController);
          final total = (tecido + extras + mao) - desc;
          final lucro = total - (tecido + extras);

          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            title: Text(pedidoExistente == null ? "Novo Pedido" : "Editar Pedido"),
            content: Builder(
              builder: (innerCtx) {
                final screenW = MediaQuery.of(innerCtx).size.width;
                // Reserve ~10% margins and clamp to a reasonable min/max
                final target = screenW * 0.9;
                final double w = target.clamp(280.0, 520.0);
                return SizedBox(
                  width: w,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [
                          Expanded(child: TextField(controller: clienteController, maxLines: 1, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: "Cliente", isDense: true), onChanged: onChanged)),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: descricaoController, maxLines: 1, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: "Serviço", isDense: true), onChanged: onChanged)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: TextField(controller: tecidoController, maxLines: 1, textInputAction: TextInputAction.next, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Valor do tecido", isDense: true), onChanged: onChanged)),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: gastosExtrasController, maxLines: 1, textInputAction: TextInputAction.next, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Gastos extras", isDense: true), onChanged: onChanged)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: TextField(controller: maoDeObraController, maxLines: 1, textInputAction: TextInputAction.next, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Mão de obra (sugerido)", isDense: true), onChanged: onChanged)),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: descontoController, maxLines: 1, textInputAction: TextInputAction.done, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Desconto", isDense: true), onChanged: onChanged)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: _InfoChip(label: 'Lucro', value: lucro)),
                          const SizedBox(width: 8),
                          Expanded(child: _InfoChip(label: 'Total', value: total)),
                        ]),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Pago'),
                            const SizedBox(width: 8),
                            Switch(
                              value: pago,
                              onChanged: (v) => setState(() => pago = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<PedidoStatus>(
                          value: status,
                          decoration: const InputDecoration(labelText: 'Status'),
                          items: const [
                            DropdownMenuItem(value: PedidoStatus.emAndamento, child: Text('Em andamento')),
                            DropdownMenuItem(value: PedidoStatus.entregue, child: Text('Concluído')),
                          ],
                          onChanged: (v) => setState(() => status = v ?? PedidoStatus.emAndamento),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
              ElevatedButton(
                onPressed: () {
                  final novoPedido = Pedido(
                    id: pedidoExistente?.id ?? const Uuid().v4(),
                    cliente: clienteController.text.trim(),
                    descricao: descricaoController.text.trim(),
                    valor: total,
                    tecido: tecido,
                    gastosExtras: extras,
                    maoDeObra: mao,
                    desconto: desc,
                    precoSugerido: (tecido + extras) * 0.5,
                    status: status,
                    dataCriacao: pedidoExistente?.dataCriacao ?? DateTime.now(),
                    dataPagamento: pago
                        ? (pedidoExistente?.dataPagamento ?? DateTime.now())
                        : null,
                  );

                  final pedidosProvider = Provider.of<PedidosProvider>(context, listen: false);
                  if (pedidoExistente == null) {
                    pedidosProvider.adicionarPedido(novoPedido);
                  } else {
                    pedidosProvider.editarPedido(pedidoExistente.id, novoPedido);
                  }

                  Navigator.pop(ctx);
                },
                child: const Text("Salvar"),
              ),
            ],
          );
        });
      },
    );
  }

  void _mostrarOpcoes(BuildContext context, Pedido pedido) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Editar"),
                onTap: () {
                  Navigator.pop(ctx);
                  _mostrarFormulario(context, pedidoExistente: pedido);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text("Concluir"),
                onTap: () {
                  // Fecha a bottom sheet antes de abrir o diálogo
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (dCtx) {
                      return AlertDialog(
                        title: const Text('Pedido concluído'),
                        content: const Text('Este pedido foi pago?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              final atualizado = Pedido(
                                id: pedido.id,
                                cliente: pedido.cliente,
                                descricao: pedido.descricao,
                                valor: pedido.valor,
                                tecido: pedido.tecido,
                                gastosExtras: pedido.gastosExtras,
                                maoDeObra: pedido.maoDeObra ?? pedido.tempo,
                                desconto: pedido.desconto,
                                itensInsumo: pedido.itensInsumo,
                                tempoHoras: pedido.tempoHoras,
                                valorHora: pedido.valorHora,
                                custoOperacional: pedido.custoOperacional,
                                margemLucroPercent: pedido.margemLucroPercent,
                                status: PedidoStatus.entregue,
                                dataCriacao: pedido.dataCriacao,
                                dataEntregaPrevista: pedido.dataEntregaPrevista,
                                dataEntregaReal: DateTime.now(),
                                dataPagamento: null,
                                precoSugerido: pedido.precoSugerido,
                                precoFinal: pedido.precoFinal,
                              );
                              Provider.of<PedidosProvider>(context, listen: false)
                                  .editarPedido(pedido.id, atualizado);
                              Navigator.pop(dCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pedido concluído (não pago)')),
                              );
                            },
                            child: const Text('Não pago'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final atualizado = Pedido(
                                id: pedido.id,
                                cliente: pedido.cliente,
                                descricao: pedido.descricao,
                                valor: pedido.valor,
                                tecido: pedido.tecido,
                                gastosExtras: pedido.gastosExtras,
                                maoDeObra: pedido.maoDeObra ?? pedido.tempo,
                                desconto: pedido.desconto,
                                itensInsumo: pedido.itensInsumo,
                                tempoHoras: pedido.tempoHoras,
                                valorHora: pedido.valorHora,
                                custoOperacional: pedido.custoOperacional,
                                margemLucroPercent: pedido.margemLucroPercent,
                                status: PedidoStatus.entregue,
                                dataCriacao: pedido.dataCriacao,
                                dataEntregaPrevista: pedido.dataEntregaPrevista,
                                dataEntregaReal: DateTime.now(),
                                dataPagamento: DateTime.now(),
                                precoSugerido: pedido.precoSugerido,
                                precoFinal: pedido.precoFinal,
                              );
                              Provider.of<PedidosProvider>(context, listen: false)
                                  .editarPedido(pedido.id, atualizado);
                              Navigator.pop(dCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pedido concluído (pago)')),
                              );
                            },
                            child: const Text('Pago'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.payments, color: Colors.blueGrey),
                title: const Text("Marcar como pago"),
                onTap: () {
                  final atualizado = Pedido(
                    id: pedido.id,
                    cliente: pedido.cliente,
                    descricao: pedido.descricao,
                    valor: pedido.valor,
                    tecido: pedido.tecido,
                    gastosExtras: pedido.gastosExtras,
                    maoDeObra: pedido.maoDeObra ?? pedido.tempo,
                    desconto: pedido.desconto,
                    itensInsumo: pedido.itensInsumo,
                    tempoHoras: pedido.tempoHoras,
                    valorHora: pedido.valorHora,
                    custoOperacional: pedido.custoOperacional,
                    margemLucroPercent: pedido.margemLucroPercent,
                    status: pedido.status,
                    dataCriacao: pedido.dataCriacao,
                    dataEntregaPrevista: pedido.dataEntregaPrevista,
                    dataEntregaReal: pedido.dataEntregaReal,
                    dataPagamento: DateTime.now(),
                    precoSugerido: pedido.precoSugerido,
                    precoFinal: pedido.precoFinal,
                  );
                  Provider.of<PedidosProvider>(context, listen: false)
                      .editarPedido(pedido.id, atualizado);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Excluir"),
                onTap: () {
                  Provider.of<PedidosProvider>(context, listen: false).removerPedido(pedido.id);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final double value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('R\$ ${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
