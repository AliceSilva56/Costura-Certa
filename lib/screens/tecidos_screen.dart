import 'package:flutter/material.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';

class TecidosScreen extends StatefulWidget {
  const TecidosScreen({super.key});

  @override
  State<TecidosScreen> createState() => _TecidosScreenState();
}

class _TecidosScreenState extends State<TecidosScreen> {
  final List<Map<String, String>> tecidos = [];

  final TextEditingController tipoController = TextEditingController();
  final TextEditingController corController = TextEditingController();
  final TextEditingController metragemController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  int? editIndex;

  @override
  void dispose() {
    tipoController.dispose();
    corController.dispose();
    metragemController.dispose();
    precoController.dispose();
    super.dispose();
  }

  void _abrirFormulario({Map<String, String>? tecido, int? index}) {
    if (tecido != null) {
      tipoController.text = tecido["tipo"]!;
      corController.text = tecido["cor"]!;
      metragemController.text = tecido["metragem"]!;
      precoController.text = tecido["preco"]!;
      editIndex = index;
    } else {
      tipoController.clear();
      corController.clear();
      metragemController.clear();
      precoController.clear();
      editIndex = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editIndex == null ? "Novo Tecido" : "Editar Tecido"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              CustomInput(
                hint: "Tipo do Tecido",
                controller: tipoController,
                prefixIcon: Icons.checkroom,
              ),
              const SizedBox(height: 12),
              CustomInput(
                hint: "Cor",
                controller: corController,
                prefixIcon: Icons.color_lens,
              ),
              const SizedBox(height: 12),
              CustomInput(
                hint: "Metragem (m)",
                controller: metragemController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.straighten,
              ),
              const SizedBox(height: 12),
              CustomInput(
                hint: "Preço (R\$)",
                controller: precoController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: editIndex == null ? "Salvar" : "Atualizar",
            onPressed: () {
              final tipo = tipoController.text;
              final cor = corController.text;

              if (tipo.isEmpty || cor.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Preencha os campos obrigatórios")),
                );
                return;
              }

              setState(() {
                if (editIndex != null) {
                  tecidos[editIndex!] = {
                    "tipo": tipo,
                    "cor": cor,
                    "metragem": metragemController.text,
                    "preco": precoController.text,
                  };
                } else {
                  tecidos.add({
                    "tipo": tipo,
                    "cor": cor,
                    "metragem": metragemController.text,
                    "preco": precoController.text,
                  });
                }
              });

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(editIndex != null
                        ? "Tecido atualizado!"
                        : "Tecido salvo!")),
              );
            },
          ),
        ],
      ),
    );
  }

  void _excluirTecido(int index) {
    setState(() {
      tecidos.removeAt(index);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Tecido excluído!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: tecidos.isEmpty
            ? const Center(
                child: Text(
                  "Nenhum tecido cadastrado.\nClique no + para adicionar.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: tecidos.length,
                itemBuilder: (context, index) {
                  final tecido = tecidos[index];
                  return CustomCard(
                    child: ListTile(
                      title: Text(tecido["tipo"]!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Cor: ${tecido["cor"]}"),
                          Text("Metragem: ${tecido["metragem"]} m"),
                          Text("Preço: R\$ ${tecido["preco"]}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _abrirFormulario(tecido: tecido, index: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _excluirTecido(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: const Color(0xFF6A1B9A),
        child: const Icon(Icons.add),
      ),
    );
  }
}
