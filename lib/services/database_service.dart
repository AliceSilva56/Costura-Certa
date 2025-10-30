import 'package:hive_flutter/hive_flutter.dart';
import '../models/pedido.dart';

class DatabaseService {
  static const String _pedidosBoxName = 'pedidos_box_v1';
  static const String _historicoBoxName = 'historico_box_v1';
  static DatabaseService? _instance;
  Box? _pedidosBox;
  Box? _historicoBox;

  DatabaseService._();

  static DatabaseService get instance => _instance ??= DatabaseService._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await instance._openBoxes();
  }

  Future<void> _openBoxes() async {
    _pedidosBox ??= await Hive.openBox(_pedidosBoxName);
    _historicoBox ??= await Hive.openBox(_historicoBoxName);
  }

  // (Config persistence removed - historicoDias agora é fixo no provider)

  Future<List<Pedido>> getHistorico() async {
    await _ensureReady();
    final values = _historicoBox!.values.cast<dynamic>();
    return values
        .whereType<Map>()
        .map((m) => Pedido.fromMap(m))
        .toList(growable: true);
  }

  Future<void> moverPedidoParaHistorico(Pedido pedido) async {
    await _ensureReady();
    await _historicoBox!.put(pedido.id, pedido.toMap());
    await _pedidosBox!.delete(pedido.id);
  }


  Future<List<Pedido>> getPedidos() async {
    await _ensureReady();
    final values = _pedidosBox!.values.cast<dynamic>();
    return values
        .whereType<Map>()
        .map((m) => Pedido.fromMap(m))
        .toList(growable: true);
  }

  Future<void> addPedido(Pedido pedido) async {
    await _ensureReady();
    await _pedidosBox!.put(pedido.id, pedido.toMap());
  }

  Future<void> updatePedido(Pedido pedido) async {
    await _ensureReady();
    await _pedidosBox!.put(pedido.id, pedido.toMap());
  }

  Future<void> removePedido(String id) async {
    await _ensureReady();
    await _pedidosBox!.delete(id);
  }

  Future<void> clearAll() async {
    await _ensureReady();
    await _pedidosBox!.clear();
  }

  Future<void> _ensureReady() async {
    if (!Hive.isBoxOpen(_pedidosBoxName) || _pedidosBox == null) {
      await _openBoxes();
    }
  }
}
//Conexão Hive/Firebase