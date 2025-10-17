import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pedidos_provider.dart';
import '../models/pedido.dart';

class ClienteDetalhesScreen extends StatelessWidget {
  const ClienteDetalhesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cliente = ModalRoute.of(context)!.settings.arguments as String?;
    final pedidosProvider = Provider.of<PedidosProvider>(context);
    final lista = pedidosProvider.pedidos.where((p) => p.cliente == (cliente ?? '')).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          cliente ?? 'Cliente',
          style: const TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final p = lista[index];
          final pago = p.dataPagamento != null;
          final cor = pago ? Colors.green : Colors.red;
          return ListTile(
            leading: Icon(pago ? Icons.check_circle : Icons.error, color: cor),
            title: Text(p.descricao),
            subtitle: Text('Total: R\$ ${p.valor.toStringAsFixed(2)} • ${pago ? 'Pago' : 'Não pago'}'),
            onTap: () => Navigator.pushNamed(context, '/detalhes', arguments: p),
          );
        },
      ),
    );
  }
}
