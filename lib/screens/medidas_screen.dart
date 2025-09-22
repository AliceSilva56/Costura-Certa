import 'package:flutter/material.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';

class MedidasScreen extends StatefulWidget {
  const MedidasScreen({super.key});

  @override
  State<MedidasScreen> createState() => _MedidasScreenState();
}

class _MedidasScreenState extends State<MedidasScreen> {
  final List<Map<String, String>> medidas = [];

  final TextEditingController clienteController = TextEditingController();
  final TextEditingController pecaController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();
  int? editIndex;

  @override
  void dispose() {
    clienteController.dispose();
    pecaController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  void _abrirFormulario({Map<String, String>? medida, int? index}) {
    if (medida != null) {
      clienteController.text = medida["cliente"]!;
      pecaController.text = medida["peca"]!;
      observacaoController.text = medida["observacao"]!;
      editIndex = index;
    } else {
      clienteController.clear();
      pecaController.clear();
      observacaoController.clear();
      editIndex = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editIndex == null ? "Nova Medida" : "Editar Medida"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              CustomInput(
                hint: "Nome do Cliente",
                controller: clienteController,
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 12),
              CustomInput(
                hint: "Peça",
                controller: pecaController,
                prefixIcon: Icons.checkroom,
              ),
              const SizedBox(height: 12),
              CustomInput(
                hint: "Observações",
                controller: observacaoController,
                prefixIcon: Icons.note,
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: editIndex == null ? "Salvar" : "Atualizar",
            onPressed: () {
              final cliente = clienteController.text;
              final peca = pecaController.text;

              if (cliente.isEmpty || peca.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Preencha os campos obrigatórios")),
                );
                return;
              }

              setState(() {
                if (editIndex != null) {
                  medidas[editIndex!] = {
                    "cliente": cliente,
                    "peca": peca,
                    "observacao": observacaoController.text,
                  };
                } else {
                  medidas.add({
                    "cliente": cliente,
                    "peca": peca,
                    "observacao": observacaoController.text,
                  });
                }
              });

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(editIndex != null ? "Medida atualizada!" : "Medida salva!"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _excluirMedida(int index) {
    setState(() {
      medidas.removeAt(index);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Medida excluída!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: medidas.isEmpty
            ? const Center(
                child: Text(
                  "Nenhuma medida cadastrada.\nClique no + para adicionar.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: medidas.length,
                itemBuilder: (context, index) {
                  final medida = medidas[index];
                  return CustomCard(
                    child: ListTile(
                      title: Text(medida["cliente"]!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Peça: ${medida["peca"]}"),
                          Text("Observação: ${medida["observacao"]}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _abrirFormulario(medida: medida, index: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _excluirMedida(index),
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
