import 'package:flutter/material.dart';
import '../models/imovel_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/app_formatters.dart';

class ImovelFinanceScreen extends StatefulWidget {
  final Imovel imovel;

  const ImovelFinanceScreen({super.key, required this.imovel});

  @override
  State<ImovelFinanceScreen> createState() => _ImovelFinanceScreenState();
}

class _ImovelFinanceScreenState extends State<ImovelFinanceScreen> {
  late double _aluguelSimulado;
  bool _modoSimulacao = false;

  @override
  void initState() {
    super.initState();
    _aluguelSimulado = widget.imovel.aluguelProposto ?? 0.0;
  }

  double get _lucroLiquidoSimulado => _aluguelSimulado - widget.imovel.custoFixoMensal;
  
  double get _capRateSimulado {
    if ((widget.imovel.valorMercadoAtual ?? 0) == 0) return 0.0;
    return ((_lucroLiquidoSimulado * 12) / widget.imovel.valorMercadoAtual!) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Estratégia Financeira", style: AppTextStyles.titleList.copyWith(fontSize: 16)),
            Text(widget.imovel.titulo, style: AppTextStyles.caption.copyWith(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_modoSimulacao ? Icons.refresh : Icons.tune, color: AppColors.primary),
            onPressed: () {
              setState(() {
                if (_modoSimulacao) {
                  _aluguelSimulado = widget.imovel.aluguelProposto ?? 0.0; // Reset
                }
                _modoSimulacao = !_modoSimulacao;
              });
            },
            tooltip: "Modo Simulação",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            _buildHealthScoreCard(),
            const SizedBox(height: 24),

            _buildSimulatorCard(),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: _buildMetricTile("Cap Rate (a.a.)", "${_capRateSimulado.toStringAsFixed(2)}%", Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricTile("Yield Mensal", "${((_lucroLiquidoSimulado / widget.imovel.investimentoTotal)*100).toStringAsFixed(2)}%", Colors.purple)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricTile("Investimento", AppFormatters.formatCurrency(widget.imovel.investimentoTotal), Colors.orange.shade800)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricTile("Valor Atual", AppFormatters.formatCurrency(widget.imovel.valorMercadoAtual), Colors.green.shade700)),
              ],
            ),

            const SizedBox(height: 24),

            Text("Payback Estimado", style: AppTextStyles.titleList.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            _buildPaybackTimeline(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  Widget _buildHealthScoreCard() {
    int score = widget.imovel.urbeScore;
    Color scoreColor = score > 70 ? Colors.green : (score > 40 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[100],
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    "$score",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: scoreColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Urbe Score", style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.bold)),
                Text(
                  score > 70 ? "Ativo de Alta Performance" : "Requer Atenção",
                  style: AppTextStyles.titleList.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  "Baseado em liquidez, vacância e ROI.",
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSimulatorCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _modoSimulacao ? AppColors.primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: _modoSimulacao ? Border.all(color: AppColors.primary) : Border.all(color: Colors.transparent),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.tune, size: 20, color: _modoSimulacao ? AppColors.primary : Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _modoSimulacao ? "SIMULADOR ATIVO" : "Simulador de Cenário", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: _modoSimulacao ? AppColors.primary : Colors.black87
                    )
                  ),
                ],
              ),
              if (_modoSimulacao)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                  child: const Text("PRO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                )
            ],
          ),
          
          const SizedBox(height: 20),
          
          Text("Aluguel Mensal Projetado", style: AppTextStyles.caption),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppFormatters.formatCurrency(_aluguelSimulado),
                style: AppTextStyles.headingMedium.copyWith(color: Colors.black87),
              ),
              Text(
                _modoSimulacao 
                  ? "${((_aluguelSimulado / (widget.imovel.aluguelProposto ?? 1) - 1) * 100).toStringAsFixed(0)}%" 
                  : "Atual",
                style: TextStyle(
                  color: _aluguelSimulado >= (widget.imovel.aluguelProposto ?? 0) ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              trackHeight: 6.0,
            ),
            child: Slider(
              value: _aluguelSimulado,
              min: 0,
              max: (widget.imovel.aluguelProposto ?? 1000) * 3,
              onChanged: (value) {
                setState(() {
                  _modoSimulacao = true;
                  _aluguelSimulado = value;
                });
              },
            ),
          ),

          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NOI (Líquido)", style: AppTextStyles.caption),
                  Text(
                    AppFormatters.formatCurrency(_lucroLiquidoSimulado),
                    style: TextStyle(
                      color: _lucroLiquidoSimulado > 0 ? Colors.green[700] : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Despesas Fixas", style: AppTextStyles.caption),
                  Text(
                    "- ${AppFormatters.formatCurrency(widget.imovel.custoFixoMensal)}",
                    style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaybackTimeline() {
    double investido = widget.imovel.investimentoTotal;
    double paybackAnos = widget.imovel.paybackMeses / 12;
    
    double progressoDemo = 0.15; 

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50), 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recuperação de Capital", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text("${paybackAnos.toStringAsFixed(1)} anos", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressoDemo,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(Colors.cyanAccent),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Investido: ${AppFormatters.formatCurrency(investido)}", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
              Text("Fase: Maturação", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }
}