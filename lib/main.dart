import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'services/pedidos_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PedidosProvider()..carregar()),
      ],
      child: const CosturaCertaApp(),
    ),
  );
}

class CosturaCertaApp extends StatelessWidget {
  const CosturaCertaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Costura Certa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // alterna entre claro/escuro
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
