import 'dart:convert';

class Imovel {
  final int? id;
  final int investidorId;
  final String titulo;
  final String enderecoCompleto;
  final double latitude;
  final double longitude;
  final double? areaM2;

  final double? valorCompra;
  final double? valorReforma;
  final double? valorMercadoAtual;

  final double? aluguelProposto;
  final double? mediaAluguelVocacao;
  final double? iptuMensal;
  final double? condominio;
  final double? outrasDespesas;

  final String? tipoImovel;
  final String? statusOcupacao;

  final List<double>? historicoAlugueis;
  final DateTime? dataConstrucao;
  final double taxaDepreciacaoAnual;

  Imovel({
    this.id,
    required this.investidorId,
    required this.titulo,
    required this.enderecoCompleto,
    required this.latitude,
    required this.longitude,
    this.areaM2,
    this.valorCompra,
    this.valorReforma,
    this.valorMercadoAtual,
    this.aluguelProposto,
    this.mediaAluguelVocacao,
    this.iptuMensal,
    this.condominio,
    this.outrasDespesas,
    this.tipoImovel,
    this.statusOcupacao,
    this.historicoAlugueis,
    this.dataConstrucao,
    this.taxaDepreciacaoAnual = 0.04,
  });

  double get investimentoTotal => (valorCompra ?? 0) + (valorReforma ?? 0);
  double get custoFixoMensal =>
      (iptuMensal ?? 0) + (condominio ?? 0) + (outrasDespesas ?? 0);
  double get lucroLiquidoMensal => (aluguelProposto ?? 0) - custoFixoMensal;

  double get capRate {
    if ((valorMercadoAtual ?? 0) == 0 && investimentoTotal == 0) return 0.0;
    double base = (valorMercadoAtual ?? 0) > 0
        ? valorMercadoAtual!
        : investimentoTotal;
    if (base == 0) return 0.0;
    return ((lucroLiquidoMensal * 12) / base) * 100;
  }

  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String)
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    return null;
  }

  factory Imovel.fromJson(Map<String, dynamic> json) {
    return Imovel(
      id: json['id'],
      investidorId: json['investidor_id'] ?? 1,
      titulo: json['titulo'] ?? '',
      enderecoCompleto: json['endereco_completo'] ?? '',
      latitude: _parseToDouble(json['latitude']) ?? 0.0,
      longitude: _parseToDouble(json['longitude']) ?? 0.0,
      areaM2: _parseToDouble(json['area_m2']),
      valorCompra: _parseToDouble(json['valor_compra']),
      valorReforma: _parseToDouble(json['valor_reforma']),
      valorMercadoAtual: _parseToDouble(json['valor_mercado_atual']),

      aluguelProposto: _parseToDouble(json['aluguel_atual']),

      iptuMensal: _parseToDouble(json['iptu_mensal']),
      condominio: _parseToDouble(json['condominio']),
      outrasDespesas: _parseToDouble(json['outras_despesas']),

      tipoImovel: json['tipo_imovel'],
      statusOcupacao: json['status_ocupacao'],

      historicoAlugueis: json['historico_alugueis'] != null
          ? (json['historico_alugueis'] as List)
                .map((e) => (e as num).toDouble())
                .toList()
          : [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'endereco_completo': enderecoCompleto,
      'latitude': latitude,
      'longitude': longitude,
      'area_m2': areaM2,
      'valor_compra': valorCompra,
      'valor_reforma': valorReforma,
      'valor_mercado_atual': valorMercadoAtual,
      'aluguel_atual': aluguelProposto,
      'iptu_mensal': iptuMensal,
      'condominio': condominio,
      'custo_mensal': outrasDespesas,
      'investidor_id': investidorId,
    };
  }
}
