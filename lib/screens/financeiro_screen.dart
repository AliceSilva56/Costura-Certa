import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pedidos_provider.dart';
import '../widgets/custom_card.dart';

class FinanceiroScreen extends StatelessWidget {
  const FinanceiroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = Provider.of<PedidosProvider>(context);
    final pedidos = pedidosProvider.pedidos;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomCard(
                    child: ListTile(
                      leading: const Icon(Icons.attach_money, color: Colors.green),
                      title: const Text("Receita Total"),
                      subtitle: Text("R\$ ${pedidosProvider.receitaTotal.toStringAsFixed(2)}"),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomCard(
                    child: ListTile(
                      leading: const Icon(Icons.shopping_bag, color: Colors.orange),
                      title: const Text("Gastos"),
                      subtitle: Text("R\$ ${pedidosProvider.gastosTecidos.toStringAsFixed(2)}"),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomCard(
                    child: ListTile(
                      leading: const Icon(Icons.trending_up, color: Colors.blue),
                      title: const Text("Lucro"),
                      subtitle: Text("R\$ ${pedidosProvider.lucroEstimado.toStringAsFixed(2)}"),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text(
              "Pedidos Recentes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...pedidos.map((pedido) {
              final total = (pedido.tempo ?? 0.0) + (pedido.tecido ?? 0.0);
              return CustomCard(
                child: ListTile(
                  title: Text(pedido.cliente),
                  subtitle: Text(
                    "Tempo: R\$ ${(pedido.tempo ?? 0.0).toStringAsFixed(2)} | Tecido: R\$ ${(pedido.tecido ?? 0.0).toStringAsFixed(2)}",
                  ),
                  trailing: Text(
                    "R\$ ${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
