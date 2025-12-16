class DashboardResumo {
  final int totalImoveis;
  final double valorPatrimonio;
  final double receitaMensalEstimada;
  final double noiAnualTotal;
  final double? capRateMedio;
  final int ativosSubperformando;

  DashboardResumo({
    required this.totalImoveis,
    required this.valorPatrimonio,
    required this.receitaMensalEstimada,
    required this.noiAnualTotal,
    this.capRateMedio,
    required this.ativosSubperformando,
  });

  factory DashboardResumo.fromJson(Map<String, dynamic> json) {
    return DashboardResumo(
      totalImoveis: json['total_imoveis'] ?? 0,
      valorPatrimonio: (json['valor_patrimonio'] ?? 0).toDouble(),
      receitaMensalEstimada: (json['receita_mensal_estimada'] ?? 0).toDouble(),
      noiAnualTotal: (json['noi_anual_total'] ?? 0).toDouble(),
      capRateMedio: json['cap_rate_medio'] != null ? (json['cap_rate_medio'] as num).toDouble() : null,
      ativosSubperformando: json['ativos_subperformando'] ?? 0,
    );
  }
}