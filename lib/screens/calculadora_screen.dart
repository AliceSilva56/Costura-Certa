import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/insumo.dart';
import '../models/pedido.dart';
import '../services/calculadora_preco_service.dart';
import '../services/pedidos_provider.dart';

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  final _formKey = GlobalKey<FormState>();

  final _clienteCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _materiaisCtrl = TextEditingController(text: '0');
  final _tempoHorasCtrl = TextEditingController(text: '0');
  final _valorHoraCtrl = TextEditingController(text: '30');
  final _custoOperacionalCtrl = TextEditingController(text: '0');
  final _margemCtrl = TextEditingController(text: '30');

  PriceBreakdown? _resultado;

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _descricaoCtrl.dispose();
    _materiaisCtrl.dispose();
    _tempoHorasCtrl.dispose();
    _valorHoraCtrl.dispose();
    _custoOperacionalCtrl.dispose();
    _margemCtrl.dispose();
    super.dispose();
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;

    final materiais = double.tryParse(_materiaisCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final tempo = double.tryParse(_tempoHorasCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final valorHora = double.tryParse(_valorHoraCtrl.text.replaceAll(',', '.')) ?? 30.0;
    final operacional = double.tryParse(_custoOperacionalCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final margem = double.tryParse(_margemCtrl.text.replaceAll(',', '.')) ?? 30.0;

    final itens = <Insumo>[
      Insumo(
        nome: 'Materiais diversos',
        tipo: 'diversos',
        unidade: 'un',
        quantidade: 1,
        custoUnitario: materiais,
      )
    ];

    final r = CalculadoraPrecoService.calcular(
      itensInsumo: itens,
      tempoHoras: tempo,
      valorHora: valorHora,
      custoOperacional: operacional,
      margemPercent: margem,
    );

    setState(() => _resultado = r);
  }

  void _salvarPedido() {
    if (_resultado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calcule primeiro para salvar.')),
      );
      return;
    }

    final id = const Uuid().v4();
    final pedido = Pedido(
      id: id,
      cliente: _clienteCtrl.text.trim().isEmpty ? 'Cliente' : _clienteCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim().isEmpty ? 'Serviço' : _descricaoCtrl.text.trim(),
      valor: _resultado!.precoSugerido,
      itensInsumo: [
        Insumo(
          nome: 'Materiais diversos',
          tipo: 'diversos',
          unidade: 'un',
          quantidade: 1,
          custoUnitario: double.tryParse(_materiaisCtrl.text.replaceAll(',', '.')) ?? 0.0,
        ),
      ],
      tempoHoras: double.tryParse(_tempoHorasCtrl.text.replaceAll(',', '.')) ?? 0.0,
      valorHora: double.tryParse(_valorHoraCtrl.text.replaceAll(',', '.')) ?? 30.0,
      custoOperacional: double.tryParse(_custoOperacionalCtrl.text.replaceAll(',', '.')) ?? 0.0,
      margemLucroPercent: double.tryParse(_margemCtrl.text.replaceAll(',', '.')) ?? 30.0,
      status: PedidoStatus.emAndamento,
      dataCriacao: DateTime.now(),
      precoSugerido: _resultado!.precoSugerido,
      precoFinal: _resultado!.precoSugerido,
    );

    context.read<PedidosProvider>().adicionarPedido(pedido);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido salvo com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Preço'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Aviso: demais funcionalidades e telas estão em desenvolvimento. Os valores são estimativas e podem variar.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _clienteCtrl,
                    decoration: const InputDecoration(labelText: 'Cliente (opcional)'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descricaoCtrl,
                    decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _materiaisCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Materiais (R\$)'),
                    validator: (v) {
                      final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                      if (d == null) return 'Informe um número válido';
                      if (d < 0) return 'Não pode ser negativo';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tempoHorasCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Tempo (horas)'),
                          validator: (v) {
                            final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                            if (d == null) return 'Número válido';
                            if (d < 0) return 'Não pode ser negativo';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _valorHoraCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Valor/hora (R\$)'),
                          validator: (v) {
                            final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                            if (d == null) return 'Número válido';
                            if (d < 0) return 'Não pode ser negativo';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _custoOperacionalCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Custo operacional (R\$)'),
                          validator: (v) {
                            final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                            if (d == null) return 'Número válido';
                            if (d < 0) return 'Não pode ser negativo';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _margemCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Margem (%)'),
                          validator: (v) {
                            final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                            if (d == null) return 'Número válido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _calcular,
                          icon: const Icon(Icons.calculate),
                          label: const Text('Calcular'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _salvarPedido,
                          icon: const Icon(Icons.save),
                          label: const Text('Salvar como Pedido'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_resultado != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Detalhamento', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _linha('Materiais', _resultado!.custoMateriais),
                      _linha('Mão de obra', _resultado!.custoMaoObra),
                      _linha('Operacional', _resultado!.custoOperacional),
                      const Divider(),
                      _linha('Subtotal', _resultado!.subtotal),
                      Text('Margem: ${_resultado!.margemPercent.toStringAsFixed(2)}%'),
                      const SizedBox(height: 4),
                      Text(
                        'Preço sugerido: R\$ ${_resultado!.precoSugerido.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _linha(String titulo, double valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo),
          Text('R\$ ${valor.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
