import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../services/pedidos_provider.dart';
import 'package:intl/intl.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = Provider.of<PedidosProvider>(context);
    final historicoMovidos = pedidosProvider.historicoPedidos;
    // Também incluir pedidos ativos que já estão concluídos e pagos (ainda não movidos)
    final elegiveis = pedidosProvider.pedidos.where((p) {
      final entregue = p.status == PedidoStatus.entregue;
      final pago = p.dataPagamento != null;
      final jaMovido = historicoMovidos.any((h) => h.id == p.id);
      return entregue && pago && !jaMovido;
    }).toList();

    final todos = [...historicoMovidos, ...elegiveis];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Histórico de Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurar histórico',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Configurações do Histórico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              ListTile(
                title: const Text('Dias até mover'),
                subtitle: const Text('2 dias (fixo)'),
                leading: const Icon(Icons.timer),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.sync),
                  label: const Text('Mover agora'),
                  onPressed: () async {
                    final provider = Provider.of<PedidosProvider>(context, listen: false);
                    final moved = await provider.moverHistoricoAgora();
                    Navigator.of(context).pop(); // fecha a drawer
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pedidos movidos: $moved')));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final pedido = todos[index];
          final custos = (pedido.tecido ?? 0) + (pedido.gastosExtras ?? 0);
          final lucro = (pedido.valor) - custos;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(pedido.cliente),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pedido.descricao),
                  const SizedBox(height: 4),
                  Text('Concluído em: ${DateFormat('dd/MM/yyyy').format(pedido.dataEntregaReal ?? DateTime.now())}'),
                  Text('Lucro: R\$ ${lucro.toStringAsFixed(2)}'),
                ],
              ),
              trailing: Text(
                "R\$ ${pedido.valor.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}