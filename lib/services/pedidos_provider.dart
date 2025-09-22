import 'package:flutter/material.dart';
import '../models/pedido.dart';

class PedidosProvider extends ChangeNotifier {
  final List<Pedido> _pedidos = [];

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);

  void adicionarPedido(Pedido pedido) {
    _pedidos.add(pedido);
    notifyListeners();
  }

  void editarPedido(String id, Pedido novoPedido) {
    final index = _pedidos.indexWhere((p) => p.id == id);
    if (index != -1) {
      _pedidos[index] = novoPedido;
      notifyListeners();
    }
  }

  void removerPedido(String id) {
    _pedidos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Receita total = soma de todos os valores dos pedidos
  double get receitaTotal =>
      _pedidos.fold(0, (soma, pedido) => soma + pedido.valor);

  /// Gastos com tecidos (se o modelo Pedido tiver esse campo)
  double get gastosTecidos =>
      _pedidos.fold(0, (soma, pedido) => soma + (pedido.tecido ?? 0));

  /// Lucro estimado = receita - gastos
  double get lucroEstimado => receitaTotal - gastosTecidos;
}
