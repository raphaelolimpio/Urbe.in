import 'package:flutter/material.dart';
import 'package:frontend/components/finace/capex_structure_card.dart';
import 'package:frontend/components/finace/finance_executive_summary.dart';
import 'package:frontend/components/finace/finance_indicators_grid.dart';
import 'package:frontend/components/finace/rental_simulator_card.dart';
import 'package:frontend/components/finace/vacancy_risk_card.dart';
import '../models/imovel_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class ImovelFinanceScreen extends StatefulWidget {
  final Imovel imovel;

  const ImovelFinanceScreen({super.key, required this.imovel});

  @override
  State<ImovelFinanceScreen> createState() => _ImovelFinanceScreenState();
}

class _ImovelFinanceScreenState extends State<ImovelFinanceScreen> {
  late double _aluguelSimulado;
  late double _valorCompraSimulado;
  late double _valorReformaSimulado;
  bool _isSimulating = false;

  final double _mediaMercado = 6500.00;

  @override
  void initState() {
    super.initState();
    _aluguelSimulado = widget.imovel.aluguelProposto ?? 0.0;
    _valorCompraSimulado = widget.imovel.valorCompra ?? 0.0;
    _valorReformaSimulado = widget.imovel.valorReforma ?? 0.0;
  }

  double get _investimentoTotal => _valorCompraSimulado + _valorReformaSimulado;
  double get _opexMensal => widget.imovel.custoFixoMensal;
  double get _noiMensal => _aluguelSimulado - _opexMensal;
  double get _noiAnual => _noiMensal * 12;
  double get _capRate =>
      _investimentoTotal == 0 ? 0.0 : (_noiAnual / _investimentoTotal) * 100;

  double get _paybackAnos {
    if (_noiAnual <= 0) return 0.0;
    return _investimentoTotal / _noiAnual;
  }

  double get _depreciacaoAnual => (_investimentoTotal * 0.70) * 0.04;

  void _resetSimulation() {
    setState(() {
      _aluguelSimulado = widget.imovel.aluguelProposto ?? 0.0;
      _isSimulating = false;
    });
  }

  void _showAdicionarCustoDialog() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Adicionar Custo (Capex)", style: AppTextStyles.titleList),
            const SizedBox(height: 8),
            Text(
              "Reforma, Mobília, Regularização...",
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Valor (R\$)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  final valor =
                      double.tryParse(controller.text.replaceAll(',', '.')) ??
                      0.0;
                  if (valor > 0) {
                    setState(() {
                      _valorReformaSimulado += valor;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "ADICIONAR",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Análise de Viabilidade",
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
          if (_isSimulating ||
              _valorReformaSimulado != (widget.imovel.valorReforma ?? 0))
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _valorReformaSimulado = widget.imovel.valorReforma ?? 0.0;
                  _resetSimulation();
                });
              },
              icon: const Icon(Icons.restore, size: 16),
              label: const Text("Resetar"),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FinanceExecutiveSummary(capRate: _capRate, noiAnual: _noiAnual),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Estrutura de Capital (CapEx)",
                  style: AppTextStyles.titleList.copyWith(fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: _showAdicionarCustoDialog,
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text("Add Capex"),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CapexStructureCard(
              valorCompra: _valorCompraSimulado,
              valorReforma: _valorReformaSimulado,
              depreciacaoAnual: _depreciacaoAnual,
              investimentoTotal: _investimentoTotal,
            ),

            const SizedBox(height: 24),

            Text(
              "Fluxo de Caixa Operacional",
              style: AppTextStyles.titleList.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              "Simule o aluguel vs média de mercado.",
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 12),
            RentalSimulatorCard(
              aluguelSimulado: _aluguelSimulado,
              mediaMercado: _mediaMercado,
              maxSliderValue: (widget.imovel.aluguelProposto ?? 4000) * 2.5,
              opexMensal: _opexMensal,
              noiMensal: _noiMensal,
              onAluguelChanged: (val) {
                setState(() {
                  _aluguelSimulado = val;
                  _isSimulating = true;
                });
              },
            ),

            const SizedBox(height: 24),

            Text(
              "Indicadores de Risco",
              style: AppTextStyles.titleList.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            FinanceIndicatorsGrid(
              paybackAnos: _paybackAnos,
              valorM2: _investimentoTotal / (widget.imovel.areaM2 ?? 1),
              statusOcupacao: widget.imovel.statusOcupacao ?? 'vago',
              yieldMensal: (_noiMensal / _investimentoTotal) * 100,
            ),
            const SizedBox(height: 12),
            VacancyRiskCard(custoMensal: _opexMensal),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
