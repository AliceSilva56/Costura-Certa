import 'package:flutter/material.dart';
import '../services/medidas_service.dart';

class MedidasScreen extends StatefulWidget {
  const MedidasScreen({super.key});

  @override
  State<MedidasScreen> createState() => _MedidasScreenState();
}

class _MedidasScreenState extends State<MedidasScreen> {
  List<Map> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await MedidasService.listar();
    if (mounted) setState(() => _items = list);
  }

  Future<void> _add() async {
    final nomeCtrl = TextEditingController();
    final obsCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Medida'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomeCtrl, maxLines: 1, decoration: const InputDecoration(labelText: 'Nome do cliente', isDense: true)),
              const SizedBox(height: 8),
              TextField(controller: obsCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Medidas/Observações', isDense: true)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await MedidasService.adicionar({
                'nome': nomeCtrl.text.trim(),
                'obs': obsCtrl.text.trim(),
                'createdAt': DateTime.now().toIso8601String(),
              });
              if (mounted) {
                Navigator.pop(ctx);
                await _load();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Medidas',
          style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Dismissible(
            key: ValueKey('${item['createdAt']}_$index'),
            background: Container(color: Colors.redAccent),
            onDismissed: (_) async {
              await MedidasService.removerAt(index);
              await _load();
            },
            child: ListTile(
              leading: const Icon(Icons.straighten, color: Color(0xFF6A1B9A)),
              title: Text(item['nome'] ?? ''),
              subtitle: Text(item['obs'] ?? ''),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }
}
