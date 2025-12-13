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

  const UrbeMap({
    super.key,
    required this.imovel,
    this.pois,
    this.raio = 250,
  });

  @override
  State<UrbeMap> createState() => _UrbeMapState();
}

class _UrbeMapState extends State<UrbeMap> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  
  bool _isSatellite = false;
  Map<String, dynamic>? _selectedPoi;

  final List<String> _categorias = ["Gastronomia", "Educação", "Saúde", "Moda", "Mercado", "Lazer", "Corporativo"];
  final Set<String> _filtrosAtivos = {"Gastronomia", "Educação", "Saúde", "Moda", "Mercado", "Lazer", "Corporativo"};

  @override
  void didUpdateWidget(UrbeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pois != oldWidget.pois && widget.pois != null && widget.pois!.isNotEmpty) {
       Future.delayed(const Duration(milliseconds: 800), () {
         _ajustarZoomSuave();
       });
    }
  }

  void _ajustarZoomSuave() {
    if (!mounted) return;
    try {
      List<LatLng> pontos = [
        LatLng(widget.imovel.latitude, widget.imovel.longitude)
      ];
      
      for (var poi in widget.pois!) {
        if (_deveMostrarPoi(poi['tipo'])) {
          double lat = poi['lat'] ?? 0.0;
          double lon = poi['lon'] ?? 0.0;
          if (lat != 0.0 && lon != 0.0) {
            pontos.add(LatLng(lat, lon));
          }
        }
      }
      
      if (pontos.length > 1) {
        final bounds = LatLngBounds.fromPoints(pontos);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(70),
            maxZoom: 17.0,
          ),
        );
      }
    } catch (e) {
      print("Erro zoom: $e");
    }
  }

  bool _deveMostrarPoi(String? tipo) {
    if (tipo == null) return false;
    String cat = PoiUtils.getCategoria(tipo);
    return _filtrosAtivos.contains(cat);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450, 
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200], 
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(widget.imovel.latitude, widget.imovel.longitude),
                initialZoom: 16.0,
                onTap: (_, __) {
                  if (_selectedPoi != null) setState(() => _selectedPoi = null);
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: _isSatellite
                      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                      : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  subdomains: _isSatellite ? const [] : const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: kIsWeb ? '' : 'com.urbe.app',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(widget.imovel.latitude, widget.imovel.longitude),
                      color: AppColors.primary.withOpacity(0.15),
                      borderStrokeWidth: 2,
                      borderColor: AppColors.primary.withOpacity(0.5),
                      useRadiusInMeter: true,
                      radius: widget.raio, 
                    ),
                  ],
                ),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),

            if (widget.pois != null && widget.pois!.isNotEmpty)
              Positioned(
                top: 10,
                left: 10,
                right: 70, 
                child: MapFilterBar(
                  categorias: _categorias,
                  filtrosAtivos: _filtrosAtivos,
                  onFilterChanged: (cat, selected) {
                    setState(() {
                      if (selected) {
                        _filtrosAtivos.add(cat);
                      } else {
                        _filtrosAtivos.remove(cat);
                      }
                      _selectedPoi = null;
                    });
                  },
                ),
              ),

            Positioned(
              top: 10,
              right: 10,
              child: MapControls(
                isSatellite: _isSatellite,
                onToggleSatellite: () => setState(() => _isSatellite = !_isSatellite),
                onResetNorth: () => _mapController.rotate(0),
                onRecenter: () => _mapController.move(
                  LatLng(widget.imovel.latitude, widget.imovel.longitude), 
                  16.0
                ),
              ),
            ),

            if (_selectedPoi != null)
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: PoiInfoCard(
                  poi: _selectedPoi!,
                  onClose: () => setState(() => _selectedPoi = null),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    markers.add(
      Marker(
        point: LatLng(widget.imovel.latitude, widget.imovel.longitude),
        width: 60,
        height: 60,
        child: Column(
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 50),
            Container(
              width: 10, height: 3,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10)
              ),
            )
          ],
        ),
      ),
    );

    if (widget.pois != null) {
      for (var poi in widget.pois!) {
        if (_deveMostrarPoi(poi['tipo'])) {
          markers.add(
            Marker(
              point: LatLng(poi['lat'] ?? 0.0, poi['lon'] ?? 0.0),
              width: 35,
              height: 35,
              child: GestureDetector(
                onTap: () => setState(() => _selectedPoi = poi),
                child: _getMarkerIcon(poi['tipo']),
              ),
            ),
          );
        }
      }
    }
    return markers;
  }

  Widget _getMarkerIcon(String? tipo) {
    final (icon, color) = PoiUtils.getVisuals(tipo);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}