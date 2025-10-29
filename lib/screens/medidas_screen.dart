import 'package:flutter/material.dart';
import '../services/medidas_service.dart';
import '../models/tipo_medida.dart';

class MedidasScreen extends StatefulWidget {
  const MedidasScreen({super.key});

  @override
  State<MedidasScreen> createState() => _MedidasScreenState();
}

class _MedidasScreenState extends State<MedidasScreen> {
  List<Map> _items = [];
  final Map<int, bool> _expandedItems = {};  // Lista vazia para manter compatibilidade com o código existente
  final List<Medida> _medidasAdicionais = []; // Lista para armazenar medidas personalizadas

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await MedidasService.listar();
      if (mounted) {
        setState(() {
          // Converter cada item para garantir que seja um Map<String, dynamic>
          _items = list.map<Map<String, dynamic>>((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            } else if (item is Map<dynamic, dynamic>) {
              return item.map((key, value) => 
                MapEntry(key.toString(), value is Map ? Map<String, dynamic>.from(value) : value)
              );
            }
            return {};
          }).toList();
        });
      }
    } catch (e) {
      print('Erro ao carregar medidas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar as medidas')),
        );
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _observacaoCtrl = TextEditingController();
  TipoMedida _tipoSelecionado = TipoMedida.corpoTodo;
  final Map<String, TextEditingController> _controladoresMedidas = {};
  final _nomeMedidaCtrl = TextEditingController();
  final _valorMedidaCtrl = TextEditingController();

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _observacaoCtrl.dispose();
    for (var controller in _controladoresMedidas.values) {
      controller.dispose();
    }
    _nomeMedidaCtrl.dispose();
    _valorMedidaCtrl.dispose();
    super.dispose();
  }

  void _inicializarControladores(List<Medida> medidas) {
    for (var medida in medidas) {
      _controladoresMedidas[medida.nome] = TextEditingController();
    }
  }

  // Método removido - funcionalidade de adicionar medida personalizada foi desativada
  void _adicionarMedidaPersonalizada() {}

  Widget _buildFormularioMedidas(TipoMedida tipo) {
    final medidas = medidasPadrao[tipo] ?? [];
    
    // Garantir que os controladores estejam inicializados
    for (var medida in medidas) {
      _controladoresMedidas[medida.nome] ??= TextEditingController();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título das medidas
        const Text('Medidas:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        // Medidas padrão
        for (var medida in medidas)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextFormField(
              controller: _controladoresMedidas[medida.nome] ??= TextEditingController(),
              decoration: InputDecoration(
                labelText: '${medida.nome} (${medida.descricao})',
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
      ],
    );
  }

  Future<void> _add() async {
    // Limpa os controladores
    _nomeCtrl.clear();
    _observacaoCtrl.clear();
    _tipoSelecionado = TipoMedida.corpoTodo;
    
    // Limpa os controladores das medidas
    _controladoresMedidas.clear();
    _inicializarControladores(medidasPadrao[_tipoSelecionado] ?? []);

    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Novo Registro de Medidas'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome do cliente
                      TextFormField(
                        controller: _nomeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nome do cliente',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            final words = value.split(' ');
                            final capitalizedWords = words.map((word) {
                              if (word.isEmpty) return '';
                              return word[0].toUpperCase() + word.substring(1).toLowerCase();
                            }).join(' ');
                            
                            if (capitalizedWords != value) {
                              _nomeCtrl.value = TextEditingValue(
                                text: capitalizedWords,
                                selection: TextSelection.collapsed(offset: capitalizedWords.length),
                              );
                            }
                          }
                        },
                        validator: (value) =>
                            value?.trim().isEmpty ?? true ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Tipo de medida
                      const Text('Tipo de Medida:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: TipoMedida.values.map((tipo) {
                          final isSelected = _tipoSelecionado == tipo;
                          return ChoiceChip(
                            label: Text(_getTipoMedidaNome(tipo)),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _tipoSelecionado = tipo;
                                _inicializarControladores(medidasPadrao[tipo] ?? []);
                              });
                            },
                            backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      
                      // Formulário de medidas
                      _buildFormularioMedidas(_tipoSelecionado),
                      
                      // Observações
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _observacaoCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Observações adicionais',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Coletar todas as medidas
                        final Map<String, dynamic> medidas = {};
                        
                        // Adicionar medidas padrão
                        for (var medida in medidasPadrao[_tipoSelecionado] ?? []) {
                          final valor = _controladoresMedidas[medida.nome]?.text.trim();
                          if (valor?.isNotEmpty ?? false) {
                            medidas[medida.nome] = valor;
                          }
                        }
                        
                        // Adicionar medidas personalizadas
                        for (var medida in _medidasAdicionais) {
                          final valor = _controladoresMedidas[medida.nome]?.text.trim();
                          if (valor?.isNotEmpty ?? false) {
                            medidas[medida.nome] = valor;
                          }
                        }
                        
                        // Verifica se pelo menos uma medida foi preenchida
                        if (medidas.isEmpty) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Preencha pelo menos uma medida')),
                            );
                          }
                          return;
                        }
                        
                        // Salva os dados
                        await MedidasService.adicionar({
                          'nome': _nomeCtrl.text.trim(),
                          'tipo': _tipoSelecionado.toString(),
                          'medidas': medidas,
                          'observacoes': _observacaoCtrl.text.trim(),
                          'createdAt': DateTime.now().toIso8601String(),
                        });
                        
                        if (mounted) {
                          Navigator.of(ctx).pop();
                          await _load();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Medidas salvas com sucesso!')),
                          );
                        }
                      }
                    } catch (e) {
                      print('Erro ao salvar medidas: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erro ao salvar as medidas. Tente novamente.')),
                        );
                      }
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getTipoMedidaNome(TipoMedida tipo) {
    switch (tipo) {
      case TipoMedida.corpoTodo:
        return '🔹 Corpo Todo';
      case TipoMedida.superior:
        return '🔹 Superior (blusas, vestidos)';
      case TipoMedida.inferior:
        return '🔹 Inferior (calças, saias, shorts)';
    }
  }

  TipoMedida _parseTipoMedida(String tipo) {
    switch (tipo) {
      case 'TipoMedida.superior':
        return TipoMedida.superior;
      case 'TipoMedida.inferior':
        return TipoMedida.inferior;
      case 'TipoMedida.corpoTodo':
      default:
        return TipoMedida.corpoTodo;
    }
  }

  String _formatarData(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }

  Widget _buildListaMedidas() {
    if (_items.isEmpty) {
      return const Center(
        child: Text('Nenhuma medida cadastrada. Clique no + para adicionar.'),
      );
    }
    
    // Inicializa o mapa de itens expandidos se necessário
    for (int i = 0; i < _items.length; i++) {
      _expandedItems.putIfAbsent(i, () => false);
    }

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        try {
          final item = _items[index];
          
          // Garantir que temos os campos necessários
          if (item['tipo'] == null) return const SizedBox.shrink();
          
          final tipo = _parseTipoMedida(item['tipo'].toString());
          final nome = item['nome']?.toString() ?? 'Sem nome';
          final createdAt = item['createdAt']?.toString() ?? '';
          final observacoes = item['observacoes']?.toString() ?? '';
          final medidas = item['medidas'] is Map ? Map<String, dynamic>.from(item['medidas']) : {};
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    nome,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(_getTipoMedidaNome(tipo)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _expandedItems[index] == true 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _expandedItems[index] = !(_expandedItems[index] ?? false);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmar'),
                                content: const Text('Tem certeza que deseja excluir esta medida?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true && mounted) {
                            try {
                              await MedidasService.removerAt(index);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Medida removida com sucesso')),
                                );
                                await _load();
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao remover medida: $e')),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _expandedItems[index] = !(_expandedItems[index] ?? false);
                    });
                  },
                ),
                if (_expandedItems[index] == true) Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lista de medidas
                      if (medidas.isNotEmpty) ...[
                        const Text('Medidas:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...medidas.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 200,
                                child: Text(
                                  e.key,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Text(e.value.toString()),
                            ],
                          ),
                        )).toList(),
                        const SizedBox(height: 12),
                      ],
                      
                      // Observações
                      if (observacoes.isNotEmpty) ...[
                        const Text('Observações:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(observacoes),
                        const SizedBox(height: 8),
                      ],
                      
                      // Data
                      Text(
                        'Data: ${_formatarData(createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } catch (e) {
          print('Erro ao construir item da lista: $e');
          return ListTile(
            title: const Text('Erro ao carregar medida'),
            subtitle: const Text('Toque para recarregar'),
            onTap: _load,
          );
        }
      },
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
      body: _buildListaMedidas(),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
    );
  }
}
