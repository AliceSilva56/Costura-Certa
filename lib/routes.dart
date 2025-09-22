import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/medidas_screen.dart';
import 'screens/tecidos_screen.dart';
import 'screens/pedidos_screen.dart';
import 'screens/financeiro_screen.dart';
import 'screens/config_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomeScreen(),
  '/medidas': (context) => const MedidasScreen(),
  '/tecidos': (context) => const TecidosScreen(),
  '/pedidos': (context) => const PedidosScreen(),
  '/financeiro': (context) => const FinanceiroScreen(),
  '/config': (context) => const ConfigScreen(),
};
