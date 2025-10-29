import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'services/pedidos_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  await AuthService.instance.init();
  
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
      themeMode: ThemeMode.light,
      routes: appRoutes,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.instance.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final logged = snapshot.data ?? false;
        return logged ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
