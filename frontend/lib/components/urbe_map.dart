import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import '../models/imovel_model.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/poi_utils.dart';
import 'poi_info_card.dart';
import 'map/map_filter_bar.dart';
import 'map/map_controls.dart';

class UrbeMap extends StatefulWidget {
  final Imovel imovel;
  final List<dynamic>? pois;
  final double raio;

  const UrbeMap({super.key, required this.imovel, this.pois, this.raio = 250});

  @override
  State<UrbeMap> createState() => _UrbeMapState();
}

class _UrbeMapState extends State<UrbeMap> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  
  // Variáveis de Interação e Distância (Mantidas!)
  Map<String, dynamic>? _selectedPoi;
  double? _distanciaSelecionada;
  LatLng? _pontoMedioLinha;

  final List<String> _categorias = [
    "Gastronomia", "Educação", "Saúde", "Moda", "Mercado", "Lazer", "Corporativo"
  ];
  final Set<String> _filtrosAtivos = {
    "Gastronomia", "Educação", "Saúde", "Moda", "Mercado", "Lazer", "Corporativo"
  };

  @override
  void didUpdateWidget(UrbeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pois != oldWidget.pois && widget.pois != null && widget.pois!.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _resetarCamera();
      });
    }
  }

  void _resetarCamera() {
    if (!mounted) return;
    _mapController.move(
      LatLng(widget.imovel.latitude, widget.imovel.longitude),
      17.5,
    );
  }

  bool _deveMostrarPoi(String? tipo) {
    if (tipo == null) return false;
    String cat = PoiUtils.getCategoria(tipo);
    return _filtrosAtivos.contains(cat);
  }

  // Lógica de cálculo de distância e ponto médio (Mantida!)
  void _selecionarPoi(dynamic poi) {
    final imovelLoc = LatLng(widget.imovel.latitude, widget.imovel.longitude);
    final poiLoc = LatLng(poi['lat'], poi['lon']);

    final Distance distance = const Distance();
    final double metros = distance.as(LengthUnit.Meter, imovelLoc, poiLoc);

    // Calcula o meio da linha para colocar a etiqueta
    final double midLat = (imovelLoc.latitude + poiLoc.latitude) / 2;
    final double midLon = (imovelLoc.longitude + poiLoc.longitude) / 2;

    setState(() {
      _selectedPoi = poi;
      _distanciaSelecionada = metros;
      _pontoMedioLinha = LatLng(midLat, midLon);
    });

    final bounds = LatLngBounds.fromPoints([imovelLoc, poiLoc]);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.only(top: 100, bottom: 200, left: 50, right: 50),
        maxZoom: 19.0,
      ),
    );
  }

  void _limparSelecao() {
    setState(() {
      _selectedPoi = null;
      _distanciaSelecionada = null;
      _pontoMedioLinha = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(widget.imovel.latitude, widget.imovel.longitude);

    return Container(
      height: 450,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 17.5,
                onTap: (_, __) => _limparSelecao(),
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                maxZoom: 19.5,
              ),
              children: [
                TileLayer(
                  // FIXO: URL do OpenStreetMap (Estilo Leaflet com prédios)
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: kIsWeb ? '' : 'com.urbe.app',
                  maxZoom: 20,
                ),

                // Linha de Conexão (Mantida!)
                if (_selectedPoi != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          center,
                          LatLng(_selectedPoi!['lat'], _selectedPoi!['lon']),
                        ],
                        strokeWidth: 4.0,
                        color: AppColors.primary,
                      ),
                    ],
                  ),

                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: center,
                      color: AppColors.primary.withOpacity(0.1),
                      borderStrokeWidth: 1,
                      borderColor: AppColors.primary.withOpacity(0.3),
                      useRadiusInMeter: true,
                      radius: widget.raio,
                    ),
                  ],
                ),

                // Marcadores (Imóvel + POIs + Etiqueta de Distância)
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),

            if (widget.pois != null && widget.pois!.isNotEmpty)
              Positioned(
                top: 10, left: 10, right: 70,
                child: MapFilterBar(
                  categorias: _categorias,
                  filtrosAtivos: _filtrosAtivos,
                  onFilterChanged: (cat, selected) {
                    setState(() {
                      selected ? _filtrosAtivos.add(cat) : _filtrosAtivos.remove(cat);
                      _limparSelecao();
                    });
                  },
                ),
              ),

            // Controles atualizados (Sem o botão de satélite)
            Positioned(
              top: 10, right: 10,
              child: MapControls(
                onResetNorth: () => _mapController.rotate(0),
                onRecenter: () {
                  _limparSelecao();
                  _resetarCamera();
                },
              ),
            ),

            if (_selectedPoi != null)
              Positioned(
                bottom: 24, left: 24, right: 24,
                child: PoiInfoCard(poi: _selectedPoi!, onClose: _limparSelecao),
              ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // 1. Marcador do Imóvel Principal
    markers.add(
      Marker(
        point: LatLng(widget.imovel.latitude, widget.imovel.longitude),
        width: 60, height: 60,
        child: Column(
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 50),
            Container(
              width: 10, height: 3,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );

    // 2. Etiqueta de Distância (Mantida!)
    if (_pontoMedioLinha != null && _distanciaSelecionada != null) {
      markers.add(
        Marker(
          point: _pontoMedioLinha!,
          width: 80, height: 30,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                ],
              ),
              child: Text(
                "${_distanciaSelecionada!.toInt()}m",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 3. Marcadores dos POIs
    if (widget.pois != null) {
      for (var poi in widget.pois!) {
        if (_deveMostrarPoi(poi['tipo'])) {
          final isSelected = _selectedPoi == poi;

          markers.add(
            Marker(
              point: LatLng(poi['lat'] ?? 0.0, poi['lon'] ?? 0.0),
              width: isSelected ? 50 : 35,
              height: isSelected ? 50 : 35,
              child: GestureDetector(
                onTap: () => _selecionarPoi(poi),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: _getMarkerIcon(poi['tipo'], isSelected),
                ),
              ),
            ),
          );
        }
      }
    }
    return markers;
  }

  Widget _getMarkerIcon(String? tipo, bool isSelected) {
    final (icon, color) = PoiUtils.getVisuals(tipo);
    return Container(
      padding: EdgeInsets.all(isSelected ? 8 : 4),
      decoration: BoxDecoration(
        color: isSelected ? color : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? Colors.white : color, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : color,
        size: isSelected ? 22 : 16,
      ),
    );
  }
}