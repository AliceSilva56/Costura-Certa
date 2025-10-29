enum TipoMedida {
  corpoTodo,
  superior,
  inferior,
}

class Medida {
  final String nome;
  final String descricao;
  final TipoMedida tipo;
  final String valor;
  final bool isPersonalizada;

  Medida({
    required this.nome,
    this.descricao = '',
    required this.tipo,
    this.valor = '',
    this.isPersonalizada = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo.toString(),
      'valor': valor,
      'isPersonalizada': isPersonalizada,
    };
  }

  factory Medida.fromMap(Map<String, dynamic> map) {
    return Medida(
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      tipo: _parseTipoMedida(map['tipo']),
      valor: map['valor'] ?? '',
      isPersonalizada: map['isPersonalizada'] ?? false,
    );
  }

  static TipoMedida _parseTipoMedida(String tipo) {
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
}

final Map<TipoMedida, List<Medida>> medidasPadrao = {
  TipoMedida.corpoTodo: [
    Medida(
      nome: 'Busto',
      descricao: 'Volta completa no ponto mais cheio do peito',
      tipo: TipoMedida.corpoTodo,
    ),
    Medida(
      nome: 'Cintura',
      descricao: 'Parte mais fina do abdômen',
      tipo: TipoMedida.corpoTodo,
    ),
    Medida(
      nome: 'Quadril',
      descricao: 'Parte mais larga do bumbum',
      tipo: TipoMedida.corpoTodo,
    ),
    Medida(
      nome: 'Altura total',
      descricao: 'Da cabeça até o chão',
      tipo: TipoMedida.corpoTodo,
    ),
    Medida(
      nome: 'Altura do busto',
      descricao: 'Do ombro até o bico do seio',
      tipo: TipoMedida.corpoTodo,
    ),
    Medida(
      nome: 'Distância entre bustos',
      descricao: 'De um bico do seio ao outro',
      tipo: TipoMedida.corpoTodo,
    ),
    Medida(
      nome: 'Altura da cintura à barra',
      descricao: 'Para saias ou calças',
      tipo: TipoMedida.corpoTodo,
    ),
    Medida(
      nome: 'Altura do quadril',
      descricao: 'Da cintura até o ponto mais largo do quadril',
      tipo: TipoMedida.corpoTodo,
    ),
    Medida(
      nome: 'Altura do joelho',
      descricao: 'Usada para vestidos, saias e calças',
      tipo: TipoMedida.corpoTodo,
    ),
  ],
  TipoMedida.superior: [
    Medida(
      nome: 'Largura das costas',
      descricao: 'De um ombro ao outro, atrás',
      tipo: TipoMedida.superior,
    ),
    Medida(
      nome: 'Ombro a ombro',
      descricao: 'Na frente',
      tipo: TipoMedida.superior,
    ),
    Medida(
      nome: 'Comprimento do braço',
      descricao: 'Do ombro até o punho',
      tipo: TipoMedida.superior,
    ),
    Medida(
      nome: 'Circunferência do braço',
      descricao: 'Parte mais grossa do braço',
      tipo: TipoMedida.superior,
    ),
    Medida(
      nome: 'Punho',
      descricao: 'Volta do punho',
      tipo: TipoMedida.superior,
    ),
    Medida(
      nome: 'Altura da cava',
      descricao: 'Do ombro até a axila',
      tipo: TipoMedida.superior,
    ),
    Medida(
      nome: 'Decote frontal',
      descricao: 'Profundidade do decote na frente',
      tipo: TipoMedida.superior,
    ),
    Medida(
      nome: 'Decote traseiro',
      descricao: 'Profundidade do decote atrás',
      tipo: TipoMedida.superior,
    ),
  ],
  TipoMedida.inferior: [
    Medida(
      nome: 'Cintura ao chão',
      descricao: 'Para comprimento total',
      tipo: TipoMedida.inferior,
    ),
    Medida(
      nome: 'Entrepernas',
      descricao: 'Da virilha até o tornozelo',
      tipo: TipoMedida.inferior,
    ),
    Medida(
      nome: 'Gancho',
      descricao: 'Do umbigo, passando entre as pernas até o cóccix',
      tipo: TipoMedida.inferior,
    ),
    Medida(
      nome: 'Coxa',
      descricao: 'Parte mais grossa da perna',
      tipo: TipoMedida.inferior,
    ),
    Medida(
      nome: 'Joelho',
      descricao: 'Circunferência do joelho',
      tipo: TipoMedida.inferior,
    ),
    Medida(
      nome: 'Tornozelo',
      descricao: 'Circunferência no fim da calça',
      tipo: TipoMedida.inferior,
    ),
    Medida(
      nome: 'Largura da cava da perna',
      descricao: 'Largura na parte superior da perna',
      tipo: TipoMedida.inferior,
    ),
    Medida(
      nome: 'Altura do quadril ao chão',
      descricao: 'Para saias e vestidos longos',
      tipo: TipoMedida.inferior,
    ),
  ],
};
