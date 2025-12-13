import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/screens/imovel_finace_screen.dart';
import '../models/imovel_model.dart';
import '../services/api_service.dart';
import '../components/urbe_map.dart';
import '../components/imovel/imovel_header.dart';
import '../components/imovel/intelligence_panel.dart';

class DetalheImovelScreen extends StatefulWidget {
  final Imovel imovel;

  const DetalheImovelScreen({super.key, required this.imovel});

  @override
  State<DetalheImovelScreen> createState() => _DetalheImovelScreenState();
}

class _DetalheImovelScreenState extends State<DetalheImovelScreen> {
  final ApiService _apiService = ApiService();

  bool _analisando = false;
  Map<String, dynamic>? _resultadoAnalise;
  double _raioSelecionado = 250;

  Future<void> _rodarAnalise() async {
    setState(() => _analisando = true);

    final resultado = await _apiService.analisarVocacao(
      widget.imovel.id!,
      raio: _raioSelecionado.toInt(),
    );

    setState(() {
      _analisando = false;
      _resultadoAnalise = resultado;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic>? poisEncontrados;
    if (_resultadoAnalise != null &&
        _resultadoAnalise!['dados_brutos'] != null) {
      poisEncontrados = _resultadoAnalise!['dados_brutos']['pois_mapa'];
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 400,
              child: UrbeMap(
                imovel: widget.imovel,
                pois: poisEncontrados,
                raio: _raioSelecionado,
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ImovelHeader(imovel: widget.imovel),
                      const Divider(),
                      const SizedBox(height: 24),

                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ImovelFinanceScreen(imovel: widget.imovel),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.05),
                                Colors.white,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.pie_chart,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Gestão Financeira",
                                      style: AppTextStyles.titleList.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "ROI, Cap Rate e Fluxo de Caixa",
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 32),

                      IntelligencePanel(
                        resultado: _resultadoAnalise,
                        raioSelecionado: _raioSelecionado,
                        isLoading: _analisando,
                        onRaioChanged: (val) =>
                            setState(() => _raioSelecionado = val),
                        onActionPressed: _rodarAnalise,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
