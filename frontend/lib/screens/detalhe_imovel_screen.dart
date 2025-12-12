import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/imovel_model.dart';
import '../services/api_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart'; 
import '../components/primary_button.dart';
import '../components/strategy_card.dart';

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
  List<Marker> _marcadores = [];

  @override
  void initState() {
    super.initState();
    _marcadores.add(
      Marker(
        point: LatLng(widget.imovel.latitude, widget.imovel.longitude),
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
      ),
    );
  }

  Future<void> _rodarAnalise() async {
    setState(() => _analisando = true);
    final resultado = await _apiService.analisarVocacao(widget.imovel.id!);
    
    setState(() {
      _analisando = false;
      _resultadoAnalise = resultado;
    });

    if (resultado != null) {
      final dadosIA = resultado['dados_brutos'];
      if (dadosIA != null && dadosIA['pois_mapa'] != null) {
        List<dynamic> pois = dadosIA['pois_mapa'];
        setState(() {
          for (var poi in pois) {
            _marcadores.add(
              Marker(
                point: LatLng(poi['lat'], poi['lon']),
                width: 30,
                height: 30,
                child: _getIconePorTipo(poi['tipo']),
              ),
            );
          }
        });
      }
    }
  }

  Widget _getIconePorTipo(String tipo) {
    IconData icone = Icons.place;
    Color cor = Colors.grey;
    switch (tipo) {
      case 'restaurant': icone = Icons.restaurant; cor = Colors.orange; break;
      case 'school': icone = Icons.school; cor = Colors.blue; break;
      case 'hospital': icone = Icons.local_hospital; cor = Colors.redAccent; break;
      case 'gym': icone = Icons.fitness_center; cor = Colors.purple; break;
      case 'supermarket': icone = Icons.shopping_cart; cor = AppColors.primary; break;
      case 'office': icone = Icons.business; cor = Colors.indigo; break;
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: cor, width: 2),
      ),
      child: Icon(icone, color: cor, size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.imovel.titulo, style: AppTextStyles.titleList),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            SizedBox(
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(widget.imovel.latitude, widget.imovel.longitude),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.urbe.app',
                  ),
                  MarkerLayer(markers: _marcadores),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: _infoBox("Valor", "R\$ ${widget.imovel.valorCompra?.toStringAsFixed(0) ?? '0'}")),
                      const SizedBox(width: 16),
                      Expanded(child: _infoBox("Área", "${widget.imovel.areaM2?.toStringAsFixed(0) ?? '0'} m²")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.imovel.enderecoCompleto, 
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  if (_resultadoAnalise == null)
                    PrimaryButton(
                      text: "Rodar Análise Estratégica",
                      onPressed: _rodarAnalise,
                      isLoading: _analisando,
                      icon: Icons.analytics_outlined,
                    ),


                  if (_resultadoAnalise != null) ...[
                    const SizedBox(height: 24),
                    Text("Inteligência de Mercado", style: AppTextStyles.titleList.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text("VOCAÇÃO SUGERIDA", style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryDark)),
                          const SizedBox(height: 4),
                          Text(
                            _resultadoAnalise!['setor_sugerido'] ?? 'Indefinido',
                            style: AppTextStyles.headingMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _resultadoAnalise!['nicho_especifico'] ?? '',
                            style: AppTextStyles.body,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StrategyCard(
                            label: "Grau de Risco", 
                            value: _resultadoAnalise!['grau_risco'] ?? 'N/A',
                            color: AppColors.riskMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StrategyCard(
                            label: "Potencial", 
                            value: _resultadoAnalise!['potencial_retorno'] ?? 'N/A',
                            color: AppColors.potentialHigh,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    Text(
                      "Os dados encontrados foram plotados no mapa.", 
                      style: AppTextStyles.caption, 
                      textAlign: TextAlign.center
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white, 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.titleList),
        ],
      ),
    );
  }
}