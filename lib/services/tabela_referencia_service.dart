import '../models/tabela_referencia_item.dart';

class TabelaReferenciaService {
  static final List<TabelaReferenciaItem> _itens = [
    TabelaReferenciaItem(
      tipo: ReferenciaTipo.conserto,
      titulo: 'Barra de calça',
      descricao: 'Ajuste de barra simples em calça',
      precoMedioMin: 20,
      precoMedioMax: 40,
      observacao: 'Valores de referência, variam por região e complexidade.',
      preset: {
        'tempoHoras': 0.5,
        'insumos': [
          {
            'nome': 'Linha',
            'tipo': 'linha',
            'unidade': 'un',
            'quantidade': 1.0,
            'custoUnitario': 2.0,
          },
        ],
      },
    ),
    TabelaReferenciaItem(
      tipo: ReferenciaTipo.conserto,
      titulo: 'Troca de zíper (calça jeans)',
      descricao: 'Remover e substituir zíper em calça jeans',
      precoMedioMin: 25,
      precoMedioMax: 60,
      observacao: 'Valores de referência, variam por região e tipo de zíper.',
      preset: {
        'tempoHoras': 1.0,
        'insumos': [
          {
            'nome': 'Zíper',
            'tipo': 'aviamento',
            'unidade': 'un',
            'quantidade': 1.0,
            'custoUnitario': 7.0,
          },
        ],
      },
    ),
    TabelaReferenciaItem(
      tipo: ReferenciaTipo.pecaDoZero,
      titulo: 'Vestido simples',
      descricao: 'Vestido básico sem forro, modelagem simples',
      precoMedioMin: 120,
      precoMedioMax: 250,
      observacao: 'Sem tecido incluso; varia com tecido e acabamento.',
      preset: {
        'tempoHoras': 4.0,
        'insumos': [
          {
            'nome': 'Tecido (viscose)',
            'tipo': 'tecido',
            'unidade': 'm',
            'quantidade': 2.0,
            'custoUnitario': 25.0,
          },
          {
            'nome': 'Linha',
            'tipo': 'linha',
            'unidade': 'un',
            'quantidade': 1.0,
            'custoUnitario': 2.0,
          },
        ],
      },
    ),
    TabelaReferenciaItem(
      tipo: ReferenciaTipo.pecaDoZero,
      titulo: 'Camisa social',
      descricao: 'Camisa com gola e punhos; acabamento médio',
      precoMedioMin: 150,
      precoMedioMax: 320,
      observacao: 'Sem tecido incluso; botões e entretela variam preço.',
      preset: {
        'tempoHoras': 5.0,
        'insumos': [
          {
            'nome': 'Tecido (tricoline)',
            'tipo': 'tecido',
            'unidade': 'm',
            'quantidade': 2.0,
            'custoUnitario': 30.0,
          },
          {
            'nome': 'Botões',
            'tipo': 'aviamento',
            'unidade': 'un',
            'quantidade': 8.0,
            'custoUnitario': 1.0,
          },
        ],
      },
    ),
  ];

  static List<TabelaReferenciaItem> listar() => List.unmodifiable(_itens);

  static List<TabelaReferenciaItem> porTipo(ReferenciaTipo tipo) =>
      _itens.where((e) => e.tipo == tipo).toList(growable: false);

  static List<TabelaReferenciaItem> buscar(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return listar();
    return _itens.where((e) {
      return e.titulo.toLowerCase().contains(q) ||
          e.descricao.toLowerCase().contains(q);
    }).toList(growable: false);
  }
}
