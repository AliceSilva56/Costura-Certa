import 'package:flutter/material.dart';
import 'pedidos_screen.dart';
import 'financeiro_screen.dart';
import 'config_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final List<Widget> _tabs = const [
    PedidosScreen(),
    FinanceiroScreen(),
    ConfigScreen(),
  ];

  final List<String> _titles = const [
    'Pedidos',
    'Financeiro',
    'Configurações',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _titles[_index],
              style: const TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            FutureBuilder<String?>(
              future: AuthService.instance.getUserName(),
              builder: (context, snapshot) {
                final name = (snapshot.data ?? '').trim();
                final greet = name.isEmpty ? 'Bem-vinda!' : 'Bem-vinda, $name!';
                return Text(
                  greet,
                  style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Calculadora de Preço',
            icon: const Icon(Icons.calculate, color: Color(0xFF6A1B9A)),
            onPressed: () => Navigator.pushNamed(context, '/calculadora'),
          ),
        ],
      ),
      body: _tabs[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        backgroundColor: const Color(0xFFFFF8E1),
        selectedItemColor: const Color(0xFF6A1B9A),
        unselectedItemColor: const Color(0xFF9E9E9E),
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Financeiro'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}
