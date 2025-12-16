import 'package:flutter/material.dart';
import 'package:frontend/components/finace/capex_structure_card.dart';
import 'package:frontend/components/finace/finance_executive_summary.dart';
import 'package:frontend/components/finace/finance_indicators_grid.dart';
import 'package:frontend/components/finace/rental_simulator_card.dart';
import 'package:frontend/components/finace/vacancy_risk_card.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/utils/app_formatters.dart';
import '../models/imovel_model.dart';
import '../services/api_service.dart';
import '../core/theme/app_text_styles.dart';

class ImovelFinanceScreen extends StatefulWidget {
  final Imovel imovel;

  const ImovelFinanceScreen({super.key, required this.imovel});

  @override
  State<ImovelFinanceScreen> createState() => _ImovelFinanceScreenState();
}

class _ImovelFinanceScreenState extends State<ImovelFinanceScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;

  double _investimentoTotalReal = 0.0;
  double _noiAnualReal = 0.0;
  double _capRateReal = 0.0;
  double _paybackReal = 0.0;
  late double _aluguelSimulado;
  late double _valorReformaSimulado;
  bool _isSimulating = false;

  final double _mediaMercado = 13500.00;

  @override
  void initState() {
    super.initState();
    _aluguelSimulado = widget.imovel.aluguelProposto ?? 0.0;
    _valorReformaSimulado = widget.imovel.valorReforma ?? 0.0;

    _carregarDadosBackend();
  }

  Future<void> _carregarDadosBackend() async {
    if (widget.imovel.id == null) return;

    try {
      final dados = await _apiService.getFinanceOverview(widget.imovel.id!);

      if (mounted) {
        setState(() {
          _investimentoTotalReal = (dados['investimento_total'] as num)
              .toDouble();
          _noiAnualReal = (dados['noi_anual'] as num).toDouble();
          _capRateReal = dados['cap_rate'] != null
              ? (dados['cap_rate'] as num).toDouble()
              : 0.0;
          _paybackReal = dados['payback_anos'] != null
              ? (dados['payback_anos'] as num).toDouble()
              : 0.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erro backend: $e");
      setState(() {
        _isLoading = false;
        _investimentoTotalReal = widget.imovel.valorCompra ?? 0;
      });
    }
  }

  double get _noiMensalSimulado =>
      _aluguelSimulado - widget.imovel.custoFixoMensal;
  double get _noiAnualSimulado => _noiMensalSimulado * 12;
  double get _investimentoTotalSimulado =>
      (widget.imovel.valorCompra ?? 0) + _valorReformaSimulado;

  @override
  Widget build(BuildContext context) {
    final double displayCapRate = _isSimulating
        ? (_investimentoTotalSimulado > 0
              ? (_noiAnualSimulado / _investimentoTotalSimulado) * 100
              : 0)
        : _capRateReal;

    final double displayNoiAnual = _isSimulating
        ? _noiAnualSimulado
        : _noiAnualReal;
    final double displayInvestimento = _isSimulating
        ? _investimentoTotalSimulado
        : _investimentoTotalReal;
    final double displayPayback = _isSimulating
        ? (displayNoiAnual > 0 ? displayInvestimento / displayNoiAnual : 0)
        : _paybackReal;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Análise Financeira",
              style: AppTextStyles.titleList.copyWith(fontSize: 16),
            ),
            Text(
              widget.imovel.titulo,
              style: AppTextStyles.caption.copyWith(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSimulating)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _aluguelSimulado = widget.imovel.aluguelProposto ?? 0.0;
                  _isSimulating = false;
                });
              },
              icon: const Icon(Icons.restore, size: 16),
              label: const Text("Resetar"),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FinanceExecutiveSummary(
                    capRate: displayCapRate,
                    noiAnual: displayNoiAnual,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Estrutura de Capital",
                    style: AppTextStyles.titleList.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  CapexStructureCard(
                    valorCompra: widget.imovel.valorCompra ?? 0.0,
                    valorReforma: _valorReformaSimulado,
                    depreciacaoAnual: (displayInvestimento * 0.70) * 0.04,
                    investimentoTotal: displayInvestimento,
                  ),

                  const SizedBox(height: 24),
                  Text(
                    "Tendência de Valorização (4 Anos)",
                    style: AppTextStyles.titleList.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    height: 180,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final historico = widget.imovel.historicoAlugueis ?? [];
                        if (historico.isEmpty)
                          return const Center(
                            child: Text("Sem histórico disponível"),
                          );

                        final maxValor = historico.reduce(
                          (a, b) => a > b ? a : b,
                        );
                        final larguraBarra =
                            (constraints.maxWidth / historico.length) * 0.5;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(historico.length, (index) {
                            final valor = historico[index];
                            final alturaDisponivel = constraints.maxHeight - 40;
                            final alturaBarra =
                                (valor / maxValor) * alturaDisponivel;

                            final isAtual = index == historico.length - 1;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Builder(
                                  builder: (context) {
                                    String textoValor;
                                    if (valor >= 1000000) {
                                      double emMilhoes = valor / 1000000;
                                      textoValor =
                                          "R\$ ${emMilhoes.toStringAsFixed(emMilhoes % 1 == 0 ? 0 : 1)}M";
                                    } else {
                                      double emMilhares = valor / 1000;
                                      textoValor =
                                          "R\$ ${emMilhares.toStringAsFixed(emMilhares % 1 == 0 ? 0 : 0)}k";
                                    }
                                    return Text(
                                      textoValor,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isAtual
                                            ? AppColors.primary
                                            : Colors.grey[600],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),

                                Container(
                                  width: larguraBarra,
                                  height: alturaBarra > 0 ? alturaBarra : 1,
                                  decoration: BoxDecoration(
                                    color: isAtual
                                        ? AppColors.primary
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  "${DateTime.now().year - (3 - index)}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Composição de Custos Mensais",
                    style: AppTextStyles.titleList.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildCostRow(
                            "Condomínio",
                            widget.imovel.condominio ?? 0,
                            Colors.orange,
                          ),
                          const Divider(),
                          _buildCostRow(
                            "IPTU Mensal",
                            widget.imovel.iptuMensal ?? 0,
                            Colors.blue,
                          ),
                          const Divider(),
                          _buildCostRow(
                            "Outras Despesas",
                            widget.imovel.outrasDespesas ?? 0,
                            Colors.grey,
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Custo Fixo Total",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                AppFormatters.formatCurrency(
                                  widget.imovel.custoFixoMensal,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Fluxo de Caixa",
                    style: AppTextStyles.titleList.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Dados reais vs. Simulação",
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),

                  RentalSimulatorCard(
                    aluguelSimulado: _aluguelSimulado,
                    mediaMercado: _mediaMercado,
                    maxSliderValue:
                        (widget.imovel.aluguelProposto ?? 2000) * 3.0,
                    opexMensal: widget.imovel.custoFixoMensal,
                    noiMensal: _isSimulating
                        ? _noiMensalSimulado
                        : (_noiAnualReal / 12),
                    onAluguelChanged: (val) {
                      setState(() {
                        _aluguelSimulado = val;
                        _isSimulating = true;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Indicadores de Performance",
                    style: AppTextStyles.titleList.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  FinanceIndicatorsGrid(
                    paybackAnos: displayPayback,
                    valorM2: displayInvestimento / (widget.imovel.areaM2 ?? 1),
                    statusOcupacao:
                        widget.imovel.statusOcupacao ?? 'Desconhecido',
                    yieldMensal:
                        (displayNoiAnual / 12) / displayInvestimento * 100,
                  ),
                  const SizedBox(height: 12),
                  VacancyRiskCard(custoMensal: widget.imovel.custoFixoMensal),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildCostRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.body),
          ],
        ),
        Text(AppFormatters.formatCurrency(value), style: AppTextStyles.body),
      ],
    );
  }
}
