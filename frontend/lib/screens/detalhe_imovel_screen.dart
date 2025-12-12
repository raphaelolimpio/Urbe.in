import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/imovel_model.dart';
import '../services/api_service.dart';

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
      // Atualiza o mapa com os POIs
      final dadosIA = resultado['dados_brutos']; // Pega do campo novo do backend
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
      case 'supermarket': icone = Icons.shopping_cart; cor = Colors.green; break;
      case 'office': icone = Icons.business; cor = Colors.indigo; break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: cor, width: 2),
      ),
      child: Icon(icone, color: cor, size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.imovel.titulo, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MAPA
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
                  // DADOS BÁSICOS
                  Row(
                    children: [
                      Expanded(child: _infoBox("Valor", "R\$ ${widget.imovel.valorCompra?.toStringAsFixed(0) ?? '0'}")),
                      const SizedBox(width: 16),
                      Expanded(child: _infoBox("Área", "${widget.imovel.areaM2?.toStringAsFixed(0) ?? '0'} m²")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(widget.imovel.enderecoCompleto, style: GoogleFonts.inter(color: Colors.grey[700])),
                  
                  const SizedBox(height: 24),
                  
                  // BOTÃO
                  if (_resultadoAnalise == null)
                    ElevatedButton.icon(
                      onPressed: _analisando ? null : _rodarAnalise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _analisando 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.analytics),
                      label: Text(
                        _analisando ? 'CALCULANDO RISCO...' : 'RODAR ANÁLISE ESTRATÉGICA',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                  // RESULTADOS DA ANÁLISE (Aqui entra a Fase 5)
                  if (_resultadoAnalise != null) ...[
                    const SizedBox(height: 24),
                    Text("Inteligência de Mercado", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    
                    // CARD PRINCIPAL (Vocação)
                    Card(
                      color: Colors.green[50],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text("Vocação Sugerida", style: TextStyle(fontSize: 12, color: Colors.green[900], fontWeight: FontWeight.bold)),
                            Text(
                              _resultadoAnalise!['setor_sugerido'] ?? 'Indefinido',
                              style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _resultadoAnalise!['nicho_especifico'] ?? '',
                              style: GoogleFonts.inter(fontSize: 14, color: Colors.green[900]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // NOVOS CARDS: RISCO E POTENCIAL
                    Row(
                      children: [
                        Expanded(
                          child: _strategyCard(
                            "Grau de Risco", 
                            _resultadoAnalise!['grau_risco'] ?? 'N/A',
                            Colors.orange[100]!, 
                            Colors.orange[900]!
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _strategyCard(
                            "Potencial", 
                            _resultadoAnalise!['potencial_retorno'] ?? 'N/A',
                            Colors.blue[100]!, 
                            Colors.blue[900]!
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    const Text("Os dados encontrados foram plotados no mapa.", style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
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
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _strategyCard(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}