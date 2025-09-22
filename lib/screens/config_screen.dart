import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  void _alterarTema(BuildContext context) {
    // Aqui você pode abrir um modal ou alternar tema
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Tema alterado!")));
  }

  void _fazerBackup(BuildContext context) {
    // Aqui você pode integrar backup local ou Firebase
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Backup realizado!")));
  }

  void _sobreApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sobre Costura Certa"),
        content: const Text(
            "Costura Certa v1.0\n\nApp para ajudar costureiros a gerenciar pedidos, medidas, tecidos e finanças.\n\nDesenvolvido com Flutter."),
        actions: [
          CustomButton(
            text: "Fechar",
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            CustomCard(
              child: ListTile(
                leading: const Icon(Icons.color_lens, color: Color(0xFF6A1B9A)),
                title: const Text("Tema"),
                subtitle: const Text("Alterar tema claro/escuro"),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD54F)),
                  onPressed: () => _alterarTema(context),
                  child: const Text("Alterar"),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: ListTile(
                leading: const Icon(Icons.backup, color: Color(0xFF6A1B9A)),
                title: const Text("Backup"),
                subtitle: const Text("Salvar ou restaurar dados do app"),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD54F)),
                  onPressed: () => _fazerBackup(context),
                  child: const Text("Backup"),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: ListTile(
                leading: const Icon(Icons.info, color: Color(0xFF6A1B9A)),
                title: const Text("Sobre"),
                subtitle: const Text("Informações sobre o app"),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD54F)),
                  onPressed: () => _sobreApp(context),
                  child: const Text("Ver"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
