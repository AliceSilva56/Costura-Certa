import 'package:flutter/material.dart';
import '../models/pedido.dart';
import 'database_service.dart';

class PedidosProvider extends ChangeNotifier {
  final List<Pedido> _pedidos = [];
  final List<Pedido> _historicoPedidos = [];

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);
  List<Pedido> get historicoPedidos => List.unmodifiable(_historicoPedidos);

  // Configurações de histórico (dias até mover para histórico)
  int historicoDias = 2; // fixo 2 dias

  // Verifica se um pedido deve ir para o histórico (concluído, pago e mais de 3 dias)
  bool _deveIrParaHistorico(Pedido pedido) {
    if (pedido.status != PedidoStatus.entregue || pedido.dataPagamento == null) {
      return false;
    }

    final dataEntrega = pedido.dataEntregaReal;
    if (dataEntrega == null) return false;

    final hoje = DateTime.now();
    final diferenca = hoje.difference(dataEntrega).inDays;
    return diferenca >= historicoDias;
  }

  // Verifica e move pedidos antigos para o histórico
  void _verificarHistorico() {
    final pedidosParaMover = _pedidos.where(_deveIrParaHistorico).toList();
    if (pedidosParaMover.isEmpty) return;

    for (var pedido in pedidosParaMover) {
      _pedidos.remove(pedido);
      _historicoPedidos.add(pedido);
      // Atualiza no banco de dados
      DatabaseService.instance.moverPedidoParaHistorico(pedido);
    }
    
    notifyListeners();
  }

  Future<void> carregar() async {
    // Carrega pedidos ativos
    final lista = await DatabaseService.instance.getPedidos();
    _pedidos
      ..clear()
      ..addAll(lista);

    // Carrega histórico
    final historico = await DatabaseService.instance.getHistorico();
    _historicoPedidos
      ..clear()
      ..addAll(historico);

    // Verifica se algum pedido deve ir para o histórico (automaticamente usando historicoDias)
    _verificarHistorico();
    
    notifyListeners();

    // Configura verificação periódica do histórico (a cada 24 horas)
    Future.delayed(const Duration(days: 1), () => _verificarHistorico());
  }

  /// Força a verificação imediata e movimentação de pedidos para o histórico.
  /// Quando chamado diretamente, move TODOS os pedidos que estejam concluídos e pagos,
  /// independente da idade (usado pelo botão 'Mover agora'). Retorna a quantidade movida.
  Future<int> moverHistoricoAgora() async {
    final toMove = _pedidos.where((p) => p.status == PedidoStatus.entregue && p.dataPagamento != null).toList();
    if (toMove.isEmpty) return 0;

    int moved = 0;
    for (var pedido in toMove) {
      _pedidos.remove(pedido);
      _historicoPedidos.add(pedido);
      await DatabaseService.instance.moverPedidoParaHistorico(pedido);
      moved++;
    }
    notifyListeners();
    return moved;
  }

  void adicionarPedido(Pedido pedido) {
    _pedidos.add(pedido);
    DatabaseService.instance.addPedido(pedido);
    notifyListeners();
  }

  void editarPedido(String id, Pedido novoPedido) {
    final index = _pedidos.indexWhere((p) => p.id == id);
    if (index != -1) {
      _pedidos[index] = novoPedido;
      DatabaseService.instance.updatePedido(novoPedido);
      notifyListeners();
    }
  }

  void removerPedido(String id) {
    _pedidos.removeWhere((p) => p.id == id);
    DatabaseService.instance.removePedido(id);
    notifyListeners();
  }

  /// Receita total = soma de todos os valores dos pedidos
  double get receitaTotal =>
      _pedidos.fold(0, (soma, pedido) => soma + (pedido.valor));

  /// Gastos com tecidos
  double get gastosTecidos =>
      _pedidos.fold(0, (soma, pedido) => soma + (pedido.tecido ?? 0));

  /// Lucro estimado = soma(total - (tecido + gastosExtras))
  double get lucroEstimado => _pedidos.fold(0, (soma, p) {
        final custos = (p.tecido ?? 0) + (p.gastosExtras ?? 0);
        final lucro = (p.valor) - custos;
        return soma + lucro;
      });
}
