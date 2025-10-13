import '../models/insumo.dart';

class PriceBreakdown {
  final double custoMateriais;
  final double custoMaoObra;
  final double custoOperacional;
  final double subtotal;
  final double margemPercent;
  final double precoSugerido;

  const PriceBreakdown({
    required this.custoMateriais,
    required this.custoMaoObra,
    required this.custoOperacional,
    required this.subtotal,
    required this.margemPercent,
    required this.precoSugerido,
  });
}

class CalculadoraPrecoService {
  static PriceBreakdown calcular({
    required List<Insumo> itensInsumo,
    required double tempoHoras,
    double valorHora = 30.0,
    double custoOperacional = 0.0,
    double margemPercent = 30.0,
  }) {
    final custoMateriais = itensInsumo.fold<double>(0.0, (s, i) => s + i.custoTotal);
    final custoMaoObra = tempoHoras * valorHora;
    final subtotal = custoMateriais + custoMaoObra + custoOperacional;
    final precoSugerido = subtotal * (1 + margemPercent / 100);

    return PriceBreakdown(
      custoMateriais: custoMateriais,
      custoMaoObra: custoMaoObra,
      custoOperacional: custoOperacional,
      subtotal: subtotal,
      margemPercent: margemPercent,
      precoSugerido: precoSugerido,
    );
  }
}
