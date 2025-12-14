import 'package:frontend/models/finance_metric.dart';

class Imovel {
  final int? id;
  final String titulo;
  final String enderecoCompleto;
  final double latitude;
  final double longitude;
  final double? areaM2;
  final double? valorCompra;
  final double? valorReforma;
  final double? valorMercadoAtual;
  final double? aluguelProposto;
  final double custoFixoMensal;
  final String? tipoImovel;
  final String? statusOcupacao;

  final FinanceMetrics? finance;

  Imovel({
    this.id,
    required this.titulo,
    required this.enderecoCompleto,
    required this.latitude,
    required this.longitude,
    this.areaM2,
    this.valorCompra,
    this.valorReforma,
    this.valorMercadoAtual,
    this.aluguelProposto,
    this.custoFixoMensal = 0.0,
    this.tipoImovel,
    this.statusOcupacao,
    this.finance,
  });

  factory Imovel.fromJson(Map<String, dynamic> json) {
    return Imovel(
      id: json['id'],
      titulo: json['titulo'],
      enderecoCompleto: json['endereco_completo'] ?? "",
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      areaM2: json['area_m2'] != null
          ? (json['area_m2'] as num).toDouble()
          : null,
      valorCompra: json['valor_compra'] != null
          ? (json['valor_compra'] as num).toDouble()
          : null,
      valorMercadoAtual: json['valor_mercado_atual'] != null
          ? (json['valor_mercado_atual'] as num).toDouble()
          : null,

      aluguelProposto: json['aluguel_atual'] != null
          ? (json['aluguel_atual'] as num).toDouble()
          : null,
      custoFixoMensal: json['custo_mensal'] != null
          ? (json['custo_mensal'] as num).toDouble()
          : 0.0,

      tipoImovel: json['tipo_imovel'],
      statusOcupacao: json['status_ocupacao'],

      finance: json['finance'] != null
          ? FinanceMetrics.fromJson(json['finance'])
          : null,
    );
  }

  double get capRate =>
      finance?.capRate != null ? (finance!.capRate! * 100) : 0.0;
}
