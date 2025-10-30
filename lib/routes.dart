import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/pedidos_screen.dart';
import 'screens/financeiro_screen.dart';
import 'screens/config_screen.dart';
import 'screens/calculadora_screen.dart';
import 'screens/login_screen.dart';
import 'screens/detalhes_pedido_screen.dart';
import 'screens/clientes_screen.dart';
import 'screens/cliente_detalhes_screen.dart';
import 'screens/medidas_screen.dart';
import 'screens/historico_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/pedidos': (context) => const PedidosScreen(),
  '/detalhes': (context) => const DetalhesPedidoScreen(),
  '/financeiro': (context) => const FinanceiroScreen(),
  '/config': (context) => const ConfigScreen(),
  '/calculadora': (context) => const CalculadoraScreen(),
  '/clientes': (context) => const ClientesScreen(),
  '/cliente_detalhes': (context) => const ClienteDetalhesScreen(),
  '/medidas': (context) => const MedidasScreen(),
  '/historico': (context) => const HistoricoScreen(),
};
