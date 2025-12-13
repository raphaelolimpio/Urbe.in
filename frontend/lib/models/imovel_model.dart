class Imovel {
  final int? id;
  final int investidorId;
  final String titulo;
  final String enderecoCompleto;
  final double latitude;
  final double longitude;
  final double? areaM2;
  
  // --- DADOS FINANCEIROS ---
  final double? valorCompra;
  final double? valorReforma;
  final double? valorMercadoAtual;
  
  // --- RENDIMENTOS E DESPESAS ---
  final double? aluguelProposto;
  final double? mediaAluguelVocacao;
  final double? iptuMensal;
  final double? condominio;
  final double? outrasDespesas;
  
  final String? tipoImovel;
  final String? statusOcupacao;

  // Novos campos (Fase 8)
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

  // --- GETTERS INTELIGENTES ---
  double get investimentoTotal => (valorCompra ?? 0) + (valorReforma ?? 0);
  
  double get valorizacaoAbsoluta => (valorMercadoAtual ?? 0) - investimentoTotal;
  
  double get percentualValorizacao {
    if (investimentoTotal == 0) return 0.0;
    return (valorizacaoAbsoluta / investimentoTotal) * 100;
  }

  double get custoFixoMensal => (iptuMensal ?? 0) + (condominio ?? 0) + (outrasDespesas ?? 0);
  
  double get custoVacanciaMensal => custoFixoMensal; // Custo de estar vazio

  double get lucroLiquidoMensal => (aluguelProposto ?? 0) - custoFixoMensal;

  double get capRate {
    if ((valorMercadoAtual ?? 0) == 0 && investimentoTotal == 0) return 0.0;
    double base = (valorMercadoAtual ?? 0) > 0 ? valorMercadoAtual! : investimentoTotal;
    if (base == 0) return 0.0;
    return ((lucroLiquidoMensal * 12) / base) * 100;
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
    if (capRate > 8) score += 40;
    else if (capRate > 5) score += 25;
    else if (capRate > 0) score += 10;

    if (statusOcupacao == 'locado') score += 30;
    else score += 10;

    if (percentualValorizacao > 20) score += 30;
    else if (percentualValorizacao > 0) score += 15;

    return score.toInt().clamp(0, 100);
  }

  // --- PARSER SEGURO (A Correção do Erro) ---
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Remove R$, espaços e converte vírgula para ponto se necessário
      String cleaned = value.replaceAll('R\$', '').replaceAll(' ', '').trim();
      return double.tryParse(cleaned);
    }
    return null;
  }

  factory Imovel.fromJson(Map<String, dynamic> json) {
    return Imovel(
      id: json['id'],
      investidorId: json['investidor_id'] ?? 1,
      titulo: json['titulo'] ?? '',
      enderecoCompleto: json['endereco_completo'] ?? '',
      // Parsing seguro para coordenadas
      latitude: _parseToDouble(json['latitude']) ?? 0.0,
      longitude: _parseToDouble(json['longitude']) ?? 0.0,
      // Parsing seguro para todos os valores financeiros
      areaM2: _parseToDouble(json['area_m2']),
      valorCompra: _parseToDouble(json['valor_compra']),
      valorReforma: _parseToDouble(json['valor_reforma']),
      valorMercadoAtual: _parseToDouble(json['valor_mercado_atual']),
      aluguelProposto: _parseToDouble(json['aluguel_atual']),
      mediaAluguelVocacao: _parseToDouble(json['media_aluguel_vocacao']),
      iptuMensal: _parseToDouble(json['iptu_mensal']),
      condominio: _parseToDouble(json['condominio']),
      outrasDespesas: _parseToDouble(json['custo_mensal']),
      
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