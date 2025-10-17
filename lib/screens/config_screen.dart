import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  void _alterarTema(BuildContext context) {
    // Aqui você pode abrir um modal ou alternar tema
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Tema alterado!")));
  }

  void _fazerBackup(BuildContext context) {
    // Aqui você pode integrar backup local ou Firebase
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Backup/Exportação: em breve")));
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
              child: FutureBuilder<List<String?>>(
                future: Future.wait([
                  AuthService.instance.getUserName(),
                  AuthService.instance.getPin(),
                ]),
                builder: (context, snapshot) {
                  final name = snapshot.data != null ? (snapshot.data![0] ?? '') : '';
                  final pin = snapshot.data != null ? (snapshot.data![1] ?? '') : '';
                  return ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFF6A1B9A)),
                    title: const Text("Perfil"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Nome: ${name.isEmpty ? 'Não informado' : name}', overflow: TextOverflow.ellipsis),
                        Text('PIN: ${pin.isEmpty ? 'Nenhum' : '••••'}', overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD54F)),
                      onPressed: () async {
                        final nameCtrl = TextEditingController(text: name);
                        final pinCtrl = TextEditingController(text: pin);
                        await showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text('Editar Perfil'),
                              content: SizedBox(
                                width: 420,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: nameCtrl,
                                      maxLines: 1,
                                      decoration: const InputDecoration(labelText: 'Nome/Ateliê', isDense: true),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: pinCtrl,
                                      maxLines: 1,
                                      keyboardType: TextInputType.number,
                                      obscureText: true,
                                      obscuringCharacter: '•',
                                      decoration: const InputDecoration(labelText: 'PIN (opcional)', isDense: true),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                                ElevatedButton(
                                  onPressed: () async {
                                    await AuthService.instance.setUserName(nameCtrl.text.trim());
                                    await AuthService.instance.setPin(pinCtrl.text.trim());
                                    if (context.mounted) {
                                      Navigator.pop(ctx);
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Perfil atualizado')),
                                      );
                                    }
                                  },
                                  child: const Text('Salvar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Editar'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: ListTile(
                leading: const Icon(Icons.people, color: Color(0xFF6A1B9A)),
                title: const Text("Clientes"),
                subtitle: const Text("Ver clientes e seus pedidos"),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD54F)),
                  onPressed: () => Navigator.pushNamed(context, '/clientes'),
                  child: const Text("Abrir"),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: ListTile(
                leading: const Icon(Icons.straighten, color: Color(0xFF6A1B9A)),
                title: const Text("Medidas"),
                subtitle: const Text("Cadastrar e consultar medidas"),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD54F)),
                  onPressed: () => Navigator.pushNamed(context, '/medidas'),
                  child: const Text("Abrir"),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD54F)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup/Exportação: em breve')),
                    );
                  },
                  child: const Text("Em breve"),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD54F)),
                  onPressed: () => _sobreApp(context),
                  child: const Text("Ver"),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text("Excluir conta"),
                subtitle: const Text("Para excluir, informe seu PIN atual"),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final currentPin = await AuthService.instance.getPin();
                    if (!mounted) return;
                    if (currentPin == null || currentPin.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Defina um PIN no perfil antes de excluir a conta.')),
                      );
                      return;
                    }
                    final pinCtrl = TextEditingController();
                    await showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text('Confirmar exclusão'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Digite seu PIN para confirmar.'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: pinCtrl,
                                maxLines: 1,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                obscuringCharacter: '•',
                                decoration: const InputDecoration(labelText: 'PIN', isDense: true),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                            ElevatedButton(
                              onPressed: () async {
                                final ok = await AuthService.instance.validatePin(pinCtrl.text.trim());
                                if (!context.mounted) return;
                                if (!ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('PIN incorreto.')), 
                                  );
                                  return;
                                }
                                await AuthService.instance.clearAll();
                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
                                }
                              },
                              child: const Text('Excluir'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Excluir'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
