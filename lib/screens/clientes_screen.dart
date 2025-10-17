import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pedidos_provider.dart';
import '../models/pedido.dart';

class ClientesScreen extends StatelessWidget {
  const ClientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = Provider.of<PedidosProvider>(context);
    final pedidos = pedidosProvider.pedidos;

    final Map<String, List<Pedido>> porCliente = {};
    for (final p in pedidos) {
      porCliente.putIfAbsent(p.cliente, () => []).add(p);
    }

    final entries = porCliente.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Clientes',
          style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final nome = entries[index].key;
          final lista = entries[index].value;
          final abertos = lista.where((p) => p.dataPagamento == null).length;
          final cor = abertos == 0
              ? Colors.green
              : (abertos >= 2 ? Colors.red : Colors.amber);
          return ListTile(
            leading: CircleAvatar(backgroundColor: cor.withOpacity(0.15), child: Icon(Icons.person, color: cor)),
            title: Text(nome),
            subtitle: Text('Pedidos: ${lista.length} • Em aberto: $abertos'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: cor),
            onTap: () => Navigator.pushNamed(context, '/cliente_detalhes', arguments: nome),
          );
        },
      ),
    );
  }
}
