import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/pedido.dart';
import '../services/pedidos_provider.dart';

class DetalhesPedidoScreen extends StatelessWidget {
  const DetalhesPedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedido = ModalRoute.of(context)!.settings.arguments as Pedido?;
    if (pedido == null) {
      return const Scaffold(body: Center(child: Text('Pedido não encontrado')));
    }
    final custos = (pedido.tecido ?? 0) + (pedido.gastosExtras ?? 0);
    final lucro = (pedido.valor) - custos;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Detalhes do Pedido',
          style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              Provider.of<PedidosProvider>(context, listen: false).removerPedido(pedido.id);
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _info('Cliente', pedido.cliente),
            _info('Serviço', pedido.descricao),
            _money('Valor do tecido', pedido.tecido ?? 0),
            _money('Gastos extras', pedido.gastosExtras ?? 0),
            _money('Mão de obra', pedido.maoDeObra ?? (pedido.tempo ?? 0)),
            _money('Desconto', pedido.desconto ?? 0),
            const Divider(height: 24),
            _money('Total', pedido.valor),
            _money('Lucro', lucro),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editar(context, pedido),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Pedido concluído'),
                          content: const Text('Este pedido foi pago?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                final novo = Pedido(
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
                                Provider.of<PedidosProvider>(context, listen: false).editarPedido(pedido.id, novo);
                                Navigator.pop(dCtx);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido concluído (não pago)')));
                              },
                              child: const Text('Não pago'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final novo = Pedido(
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
                                Provider.of<PedidosProvider>(context, listen: false).editarPedido(pedido.id, novo);
                                Navigator.pop(dCtx);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido concluído (pago)')));
                              },
                              child: const Text('Pago'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Concluir'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _money(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('R\$ ${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _editar(BuildContext context, Pedido pedidoExistente) {
    final clienteController = TextEditingController(text: pedidoExistente.cliente);
    final descricaoController = TextEditingController(text: pedidoExistente.descricao);
    final tecidoController = TextEditingController(text: (pedidoExistente.tecido ?? 0).toString());
    final gastosExtrasController = TextEditingController(text: (pedidoExistente.gastosExtras ?? 0).toString());
    final maoDeObraController = TextEditingController(text: (pedidoExistente.maoDeObra ?? 0).toString());
    final descontoController = TextEditingController(text: (pedidoExistente.desconto ?? 0).toString());
    PedidoStatus status = pedidoExistente.status ?? PedidoStatus.emAndamento;
    bool pago = pedidoExistente.dataPagamento != null;

    double parse(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        void onChanged(_) => setState(() {});
        final tecido = parse(tecidoController);
        final extras = parse(gastosExtrasController);
        final mao = parse(maoDeObraController);
        final desc = parse(descontoController);
        final total = (tecido + extras + mao) - desc;

        return AlertDialog(
          title: const Text('Editar Pedido'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Expanded(child: TextField(controller: clienteController, decoration: const InputDecoration(labelText: 'Cliente'), onChanged: onChanged)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: descricaoController, decoration: const InputDecoration(labelText: 'Serviço'), onChanged: onChanged)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: tecidoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor do tecido'), onChanged: onChanged)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: gastosExtrasController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gastos extras'), onChanged: onChanged)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: maoDeObraController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Mão de obra'), onChanged: onChanged)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: descontoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Desconto'), onChanged: onChanged)),
                ]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Pago'),
                    const SizedBox(width: 8),
                    Switch(value: pago, onChanged: (v) => setState(() => pago = v)),
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
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final novoPedido = Pedido(
                  id: pedidoExistente.id,
                  cliente: clienteController.text.trim(),
                  descricao: descricaoController.text.trim(),
                  valor: total,
                  tecido: tecido,
                  gastosExtras: extras,
                  maoDeObra: mao,
                  desconto: desc,
                  itensInsumo: pedidoExistente.itensInsumo,
                  tempoHoras: pedidoExistente.tempoHoras,
                  valorHora: pedidoExistente.valorHora,
                  custoOperacional: pedidoExistente.custoOperacional,
                  margemLucroPercent: pedidoExistente.margemLucroPercent,
                  status: status,
                  dataCriacao: pedidoExistente.dataCriacao,
                  dataEntregaPrevista: pedidoExistente.dataEntregaPrevista,
                  dataEntregaReal: pedidoExistente.dataEntregaReal,
                  dataPagamento: pago
                      ? (pedidoExistente.dataPagamento ?? DateTime.now())
                      : null,
                  precoSugerido: pedidoExistente.precoSugerido,
                  precoFinal: pedidoExistente.precoFinal,
                );
                Provider.of<PedidosProvider>(context, listen: false).editarPedido(pedidoExistente.id, novoPedido);
                Navigator.pop(ctx);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      }),
    );
  }
}
