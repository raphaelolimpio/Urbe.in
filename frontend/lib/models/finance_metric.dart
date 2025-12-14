class FinanceMetrics {
  final double? aluguelAtual;
  final double? custoMensal;
  final double noiAnual;
  final double? capRate;
  final double? roi;
  final String performance;

  FinanceMetrics({
    this.aluguelAtual,
    this.custoMensal,
    required this.noiAnual,
    this.capRate,
    this.roi,
    required this.performance,
  });

  factory FinanceMetrics.fromJson(Map<String, dynamic> json) {
    return FinanceMetrics(
      aluguelAtual: json['aluguel_atual'] != null
          ? (json['aluguel_atual'] as num).toDouble()
          : null,
      custoMensal: json['custo_mensal'] != null
          ? (json['custo_mensal'] as num).toDouble()
          : null,
      noiAnual: (json['noi_anual'] as num).toDouble(),
      capRate: json['cap_rate'] != null
          ? (json['cap_rate'] as num).toDouble()
          : null,
      roi: json['roi'] != null ? (json['roi'] as num).toDouble() : null,
      performance: json['performance'] ?? "Sem dados",
    );
  }
}
