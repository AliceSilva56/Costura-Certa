import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/pedido.dart';
import '../services/pedidos_provider.dart';
import '../services/pedidos_provider.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = Provider.of<PedidosProvider>(context);

    return Scaffold(
    
      body: ListView.builder(
        itemCount: pedidosProvider.pedidos.length,
        itemBuilder: (context, index) {
          final pedido = pedidosProvider.pedidos[index];
          return ListTile(
            title: Text(pedido.cliente),
            subtitle: Text(pedido.descricao),
            trailing: Text("R\$ ${pedido.valor.toStringAsFixed(2)}"),
            onLongPress: () {
              _mostrarOpcoes(context, pedido);
            },
          );
        },
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
    final valorController = TextEditingController(text: pedidoExistente?.valor.toString() ?? "");

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(pedidoExistente == null ? "Novo Pedido" : "Editar Pedido"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: clienteController, decoration: const InputDecoration(labelText: "Cliente")),
              TextField(controller: descricaoController, decoration: const InputDecoration(labelText: "Descrição")),
              TextField(
                controller: valorController,
                decoration: const InputDecoration(labelText: "Valor"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                final novoPedido = Pedido(
                  id: pedidoExistente?.id ?? const Uuid().v4(),
                  cliente: clienteController.text,
                  descricao: descricaoController.text,
                  valor: double.tryParse(valorController.text) ?? 0,
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
