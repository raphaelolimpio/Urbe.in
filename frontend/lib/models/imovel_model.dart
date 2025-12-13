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
  });

  double get investimentoTotal => (valorCompra ?? 0) + (valorReforma ?? 0);

  double get valorizacaoAbsoluta =>
      (valorMercadoAtual ?? 0) - investimentoTotal;

  double get percentualValorizacao {
    if (investimentoTotal == 0) return 0.0;
    return (valorizacaoAbsoluta / investimentoTotal) * 100;
  }

  double get custoFixoMensal =>
      (iptuMensal ?? 0) + (condominio ?? 0) + (outrasDespesas ?? 0);

  double get lucroLiquidoMensal => (aluguelProposto ?? 0) - custoFixoMensal;

  double get capRate {
    if ((valorMercadoAtual ?? 0) == 0) return 0.0;
    return ((lucroLiquidoMensal * 12) / valorMercadoAtual!) * 100;
  }

  double get cashOnCash {
    if (investimentoTotal == 0) return 0.0;
    return ((lucroLiquidoMensal * 12) / investimentoTotal) * 100;
  }

  double get paybackMeses {
    if (lucroLiquidoMensal <= 0) return 0;
    return investimentoTotal / lucroLiquidoMensal;
  }

  int get urbeScore {
    double score = 0;
    if (capRate > 8)
      score += 40;
    else if (capRate > 5)
      score += 25;
    else if (capRate > 0)
      score += 10;
    if (statusOcupacao == 'locado')
      score += 30;
    else
      score += 10;
    if (percentualValorizacao > 20)
      score += 30;
    else if (percentualValorizacao > 0)
      score += 15;
    return score.toInt().clamp(0, 100);
  }

  factory Imovel.fromJson(Map<String, dynamic> json) {
    return Imovel(
      id: json['id'],
      investidorId: json['investidor_id'] ?? 1,
      titulo: json['titulo'] ?? '',
      enderecoCompleto: json['endereco_completo'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      areaM2: json['area_m2'] != null ? (json['area_m2']).toDouble() : null,
      valorCompra: json['valor_compra'] != null
          ? (json['valor_compra']).toDouble()
          : null,
      valorReforma: json['valor_reforma'] != null
          ? (json['valor_reforma']).toDouble()
          : null,
      valorMercadoAtual: json['valor_mercado_atual'] != null
          ? (json['valor_mercado_atual']).toDouble()
          : null,
      aluguelProposto: json['aluguel_atual'] != null
          ? (json['aluguel_atual']).toDouble()
          : null,
      mediaAluguelVocacao: json['media_aluguel_vocacao'] != null
          ? (json['media_aluguel_vocacao']).toDouble()
          : null,
      iptuMensal: json['iptu_mensal'] != null
          ? (json['iptu_mensal']).toDouble()
          : null,
      condominio: json['condominio'] != null
          ? (json['condominio']).toDouble()
          : null,
      outrasDespesas: json['custo_mensal'] != null
          ? (json['custo_mensal']).toDouble()
          : null,
      tipoImovel: json['tipo_imovel'],
      statusOcupacao: json['status_ocupacao'],
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
