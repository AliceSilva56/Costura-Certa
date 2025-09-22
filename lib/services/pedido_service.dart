import 'package:flutter/material.dart';

class PedidoService {
  // Lista reativa que notifica mudanças em pedidos
  static final ValueNotifier<List<Map<String, dynamic>>> pedidosNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);
}
