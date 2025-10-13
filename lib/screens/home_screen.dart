import 'package:flutter/material.dart';
import 'medidas_screen.dart';
import 'pedidos_screen.dart';
import 'financeiro_screen.dart';
import 'config_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MedidasScreen(),
    PedidosScreen(),
    FinanceiroScreen(),
    ConfigScreen(),
  ];

  final List<String> _titles = [
    "Medidas",
    "Pedidos",
    "Financeiro",
    "Configurações",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFF6A1B9A)),
        actions: [
          IconButton(
            tooltip: 'Calculadora de Preço',
            icon: const Icon(Icons.calculate),
            onPressed: () => Navigator.pushNamed(context, '/calculadora'),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFFFD54F),
        unselectedItemColor: const Color(0xFF6A1B9A),
        backgroundColor: const Color(0xFFFFF8E1),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.straighten),
            label: "Medidas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Pedidos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Financeiro",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Config",
          ),
        ],
      ),
    );
  }
}
