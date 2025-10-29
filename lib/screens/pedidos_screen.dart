import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../models/pedido.dart';
import '../services/pedidos_provider.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  PedidoStatus? _statusFilter; // null = todos
  bool _paidOnly = false;

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = Provider.of<PedidosProvider>(context);

    final pedidosFiltrados = pedidosProvider.pedidos.where((p) {
      final statusOk = _statusFilter == null || (p.status ?? PedidoStatus.emAndamento) == _statusFilter;
      final pagoOk = !_paidOnly || p.dataPagamento != null;
      return statusOk && pagoOk;
    }).toList();

    return Scaffold(
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<PedidoStatus?>(
                    value: _statusFilter,
                    decoration: const InputDecoration(labelText: 'Status', isDense: true),
                    items: const [
                      DropdownMenuItem<PedidoStatus?>(value: null, child: Text('Todos')),
                      DropdownMenuItem<PedidoStatus?>(value: PedidoStatus.emAndamento, child: Text('Em andamento')),
                      DropdownMenuItem<PedidoStatus?>(value: PedidoStatus.entregue, child: Text('Concluído')),
                    ],
                    onChanged: (v) => setState(() => _statusFilter = v),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Pagos'),
                    const SizedBox(width: 6),
                    Switch(
                      value: _paidOnly,
                      onChanged: (v) => setState(() => _paidOnly = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: pedidosFiltrados.length,
              itemBuilder: (context, index) {
                final pedido = pedidosFiltrados[index];
          final custos = (pedido.tecido ?? 0) + (pedido.gastosExtras ?? 0);
          final lucro = (pedido.valor) - custos;
          final status = pedido.status ?? PedidoStatus.emAndamento;
          final color = status == PedidoStatus.emAndamento
              ? Colors.amber
              : Colors.green;
          final pago = pedido.dataPagamento != null;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(
                status == PedidoStatus.emAndamento
                    ? Icons.timelapse
                    : Icons.check_circle,
                color: color,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pedido.cliente, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (pedido.telefone.isNotEmpty || pedido.email.isNotEmpty) 
                  Text(
                    '${pedido.telefone.isNotEmpty ? pedido.telefone : ''}${pedido.telefone.isNotEmpty && pedido.email.isNotEmpty ? ' • ' : ''}${pedido.email.isNotEmpty ? pedido.email : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pedido.descricao),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: status == PedidoStatus.entregue ? Colors.green[50] : Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: status == PedidoStatus.entregue ? Colors.green[100]! : Colors.amber[100]!),
                      ),
                      child: Text(
                        status == PedidoStatus.entregue ? 'Concluído' : 'Em andamento',
                        style: TextStyle(
                          color: status == PedidoStatus.entregue ? Colors.green[800] : Colors.amber[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: pago ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: pago ? Colors.green[100]! : Colors.red[100]!),
                      ),
                      child: Text(
                        pago ? 'Pago' : 'Não pago',
                        style: TextStyle(
                          color: pago ? Colors.green[800] : Colors.red[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Lucro: R\$ ${lucro.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                if (pedido.dataEntregaPrevista != null) 
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Entrega: ${DateFormat('dd/MM/yyyy').format(pedido.dataEntregaPrevista!)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
            isThreeLine: true,
            trailing: Text("R\$ ${pedido.valor.toStringAsFixed(2)}"),
            onTap: () => Navigator.pushNamed(context, '/detalhes', arguments: pedido),
            onLongPress: () => _mostrarOpcoes(context, pedido),
          );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }

  void _mostrarFormulario(BuildContext context, {Pedido? pedidoExistente}) {
    final clienteController = TextEditingController(text: pedidoExistente?.cliente ?? "");
    final emailController = TextEditingController(text: pedidoExistente?.email ?? "");
    final telefoneController = TextEditingController(text: pedidoExistente?.telefone ?? "");
    final descricaoController = TextEditingController(text: pedidoExistente?.descricao ?? "");
    final tecidoController = TextEditingController(text: (pedidoExistente?.tecido ?? 0).toString());
    final gastosExtrasController = TextEditingController(text: (pedidoExistente?.gastosExtras ?? 0).toString());
    final maoDeObraController = TextEditingController(text: (pedidoExistente?.maoDeObra ?? 0).toString());
    final descontoController = TextEditingController(text: (pedidoExistente?.desconto ?? 0).toString());
    PedidoStatus status = pedidoExistente?.status ?? PedidoStatus.emAndamento;
    bool pago = (pedidoExistente?.dataPagamento != null);
    DateTime? dataEntregaPrevista = pedidoExistente?.dataEntregaPrevista;
    final dataEntregaController = TextEditingController(
      text: pedidoExistente?.dataEntregaPrevista != null 
          ? DateFormat('dd/MM/yyyy').format(pedidoExistente!.dataEntregaPrevista!) 
          : '',
    );

    double parse(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          // Funções auxiliares
          void recomputeIfEmptyMaoDeObra() {
            final tecido = parse(tecidoController);
            final extras = parse(gastosExtrasController);
            final suggested = (tecido + extras) * 5;
            if ((pedidoExistente == null && (maoDeObraController.text.isEmpty || parse(maoDeObraController) == 0))) {
              maoDeObraController.text = suggested.toStringAsFixed(2);
            }
          }

          void onChanged(_) => setState(() {});

          // Inicializa valores
          recomputeIfEmptyMaoDeObra();
          final tecido = parse(tecidoController);
          final extras = parse(gastosExtrasController);
          final mao = parse(maoDeObraController);
          final desc = parse(descontoController);
          final total = (tecido + extras + mao) - desc;
          final lucro = total - (tecido + extras);

          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            title: Text(pedidoExistente == null ? 'Novo Pedido' : 'Editar Pedido'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: clienteController,
                    maxLines: 1,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: "Cliente",
                      isDense: true,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        final cursorPosition = clienteController.selection;
                        clienteController.text = _capitalizeFirstLetter(value);
                        clienteController.selection = cursorPosition;
                      }
                      onChanged(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: emailController,
                          maxLines: 1,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "E-mail",
                            isDense: true,
                          ),
                          onChanged: onChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: telefoneController,
                          maxLines: 1,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "Telefone",
                            isDense: true,
                          ),
                          onChanged: onChanged,
                        ),
                      ),
                    ],
                  ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descricaoController,
                          maxLines: 1,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: "Serviço",
                            isDense: true,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              final cursorPosition = descricaoController.selection;
                              descricaoController.text = _capitalizeFirstLetter(value);
                              descricaoController.selection = cursorPosition;
                            }
                            onChanged(value);
                          },
                        ),
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: TextField(controller: tecidoController, maxLines: 1, textInputAction: TextInputAction.next, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Valor do tecido", isDense: true), onChanged: onChanged)),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: gastosExtrasController, maxLines: 1, textInputAction: TextInputAction.next, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Gastos extras", isDense: true), onChanged: onChanged)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: TextField(controller: maoDeObraController, maxLines: 1, textInputAction: TextInputAction.next, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Mão de obra (sugerido)", isDense: true), onChanged: onChanged)),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: descontoController, maxLines: 1, textInputAction: TextInputAction.done, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Desconto", isDense: true), onChanged: onChanged)),
                        ]),
                        const SizedBox(height: 8),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: dataEntregaController,
                          decoration: const InputDecoration(
                            labelText: 'Prazo de Conclusão',
                            suffixIcon: Icon(Icons.calendar_today),
                            isDense: true,
                          ),
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: dataEntregaPrevista ?? DateTime.now().add(const Duration(days: 7)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                              locale: const Locale('pt', 'BR'),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.blue, // Cor principal do cabeçalho
                                      onPrimary: Colors.white, // Cor do texto do cabeçalho
                                      onSurface: Colors.black, // Cor do texto dos dias
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue, // Cor dos botões
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              dataEntregaPrevista = picked;
                              dataEntregaController.text = DateFormat('dd/MM/yyyy').format(picked);
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: _InfoChip(label: 'Lucro', value: lucro)),
                          const SizedBox(width: 8),
                          Expanded(child: _InfoChip(label: 'Total', value: total)),
                        ]),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Pago'),
                            const SizedBox(width: 8),
                            Switch(
                              value: pago,
                              onChanged: (v) => setState(() => pago = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<PedidoStatus>(
                          value: status,
                          decoration: const InputDecoration(labelText: 'Status'),
                          items: const [
                            DropdownMenuItem(value: PedidoStatus.emAndamento, child: Text('Em andamento')),
                            DropdownMenuItem(value: PedidoStatus.entregue, child: Text('Concluído')),
                          ],
                          onChanged: (v) => setState(() => status = v ?? PedidoStatus.emAndamento),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final pedidosProvider = Provider.of<PedidosProvider>(context, listen: false);
                    final pedido = Pedido(
                      id: pedidoExistente?.id ?? const Uuid().v4(),
                      cliente: clienteController.text.trim(),
                      email: emailController.text.trim(),
                      telefone: telefoneController.text.trim(),
                      descricao: descricaoController.text.trim(),
                      valor: total,
                      tecido: tecido == 0 ? null : tecido,
                      gastosExtras: extras == 0 ? null : extras,
                      maoDeObra: mao == 0 ? null : mao,
                      desconto: desc == 0 ? null : desc,
                      status: status,
                      dataCriacao: pedidoExistente?.dataCriacao ?? DateTime.now(),
                      dataEntregaPrevista: dataEntregaPrevista,
                      dataPagamento: pago ? (pedidoExistente?.dataPagamento ?? DateTime.now()) : null,
                    );

                    if (pedidoExistente == null) {
                      await pedidosProvider.adicionarPedido(pedido);
                    } else {
                      await pedidosProvider.editarPedido(pedidoExistente!.id, pedido);
                    }

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao salvar pedido: $e')),
                      );
                    }
                  }
                  },
                child: const Text('Salvar'),
              ),
            ],
          );
        });
      },
    );
  }

  void _mostrarOpcoes(BuildContext context, Pedido pedido) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Editar"),
                onTap: () {
                  Navigator.pop(ctx);
                  _mostrarFormulario(context, pedidoExistente: pedido);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text("Concluir"),
                onTap: () {
                  // Fecha a bottom sheet antes de abrir o diálogo
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (dCtx) {
                      return AlertDialog(
                        title: const Text('Pedido concluído'),
                        content: const Text('Este pedido foi pago?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              final atualizado = Pedido(
                                id: pedido.id,
                                cliente: pedido.cliente,
                                descricao: pedido.descricao,
                                valor: pedido.valor,
                                tecido: pedido.tecido,
                                gastosExtras: pedido.gastosExtras,
                                maoDeObra: pedido.maoDeObra ?? pedido.tempo,
                                desconto: pedido.desconto,
                                itensInsumo: pedido.itensInsumo,
                                tempoHoras: pedido.tempoHoras,
                                valorHora: pedido.valorHora,
                                custoOperacional: pedido.custoOperacional,
                                margemLucroPercent: pedido.margemLucroPercent,
                                status: PedidoStatus.entregue,
                                dataCriacao: pedido.dataCriacao,
                                dataEntregaPrevista: pedido.dataEntregaPrevista,
                                dataEntregaReal: DateTime.now(),
                                dataPagamento: null,
                                precoSugerido: pedido.precoSugerido,
                                precoFinal: pedido.precoFinal,
                              );
                              Provider.of<PedidosProvider>(context, listen: false)
                                  .editarPedido(pedido.id, atualizado);
                              Navigator.pop(dCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pedido concluído (não pago)')),
                              );
                            },
                            child: const Text('Não pago'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final atualizado = Pedido(
                                id: pedido.id,
                                cliente: pedido.cliente,
                                descricao: pedido.descricao,
                                valor: pedido.valor,
                                tecido: pedido.tecido,
                                gastosExtras: pedido.gastosExtras,
                                maoDeObra: pedido.maoDeObra ?? pedido.tempo,
                                desconto: pedido.desconto,
                                itensInsumo: pedido.itensInsumo,
                                tempoHoras: pedido.tempoHoras,
                                valorHora: pedido.valorHora,
                                custoOperacional: pedido.custoOperacional,
                                margemLucroPercent: pedido.margemLucroPercent,
                                status: PedidoStatus.entregue,
                                dataCriacao: pedido.dataCriacao,
                                dataEntregaPrevista: pedido.dataEntregaPrevista,
                                dataEntregaReal: DateTime.now(),
                                dataPagamento: DateTime.now(),
                                precoSugerido: pedido.precoSugerido,
                                precoFinal: pedido.precoFinal,
                              );
                              Provider.of<PedidosProvider>(context, listen: false)
                                  .editarPedido(pedido.id, atualizado);
                              Navigator.pop(dCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pedido concluído (pago)')),
                              );
                            },
                            child: const Text('Pago'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.payments, color: Colors.blueGrey),
                title: const Text("Marcar como pago"),
                onTap: () {
                  final atualizado = Pedido(
                    id: pedido.id,
                    cliente: pedido.cliente,
                    descricao: pedido.descricao,
                    valor: pedido.valor,
                    tecido: pedido.tecido,
                    gastosExtras: pedido.gastosExtras,
                    maoDeObra: pedido.maoDeObra ?? pedido.tempo,
                    desconto: pedido.desconto,
                    itensInsumo: pedido.itensInsumo,
                    tempoHoras: pedido.tempoHoras,
                    valorHora: pedido.valorHora,
                    custoOperacional: pedido.custoOperacional,
                    margemLucroPercent: pedido.margemLucroPercent,
                    status: pedido.status,
                    dataCriacao: pedido.dataCriacao,
                    dataEntregaPrevista: pedido.dataEntregaPrevista,
                    dataEntregaReal: pedido.dataEntregaReal,
                    dataPagamento: DateTime.now(),
                    precoSugerido: pedido.precoSugerido,
                    precoFinal: pedido.precoFinal,
                  );
                  Provider.of<PedidosProvider>(context, listen: false)
                      .editarPedido(pedido.id, atualizado);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Excluir"),
                onTap: () {
                  Provider.of<PedidosProvider>(context, listen: false).removerPedido(pedido.id);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final double value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('R\$ ${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
