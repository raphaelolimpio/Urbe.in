import 'package:flutter/material.dart';
import 'package:frontend/components/finace/capex_structure_card.dart';
import 'package:frontend/components/finace/finance_executive_summary.dart';
import 'package:frontend/components/finace/finance_indicators_grid.dart';
import 'package:frontend/components/finace/rental_simulator_card.dart';
import 'package:frontend/components/finace/vacancy_risk_card.dart';
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
}
