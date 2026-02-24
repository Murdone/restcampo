import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

void main() => runApp(const MaterialApp(home: ComoLlegarScreen()));

class ComoLlegarScreen extends StatefulWidget {
  const ComoLlegarScreen({super.key});

  @override
  State<ComoLlegarScreen> createState() => _ComoLlegarScreenState();
}

class _ComoLlegarScreenState extends State<ComoLlegarScreen> {
  final MapController _mapController = MapController();

  // 📍 Destino (tu dirección)
  static const LatLng destino = LatLng(-39.2753997, -71.9681422);

  // Estado
  LatLng? _miUbicacion;
  List<LatLng> _ruta = [];
  bool _cargandoRuta = false;

  // ======================
  // UI helpers (Zoom)
  // ======================
  void _zoomIn() {
    final nextZoom = (_mapController.camera.zoom + 1)
        .clamp(1.0, 19.0)
        .toDouble();
    _mapController.move(_mapController.camera.center, nextZoom);
  }

  void _zoomOut() {
    final nextZoom = (_mapController.camera.zoom - 1)
        .clamp(1.0, 19.0)
        .toDouble();
    _mapController.move(_mapController.camera.center, nextZoom);
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: Colors.black87),
        ),
      ),
    );
  }

  // ======================
  // Snack helper
  // ======================
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ======================
  // 1) Ubicación (GPS)
  // ======================
  Future<bool> _asegurarPermisosYServicio() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _snack('Activa el GPS/Ubicación del dispositivo');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _snack('Permiso de ubicación denegado');
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      _snack('Permiso denegado permanentemente. Actívalo en Ajustes.');
      return false;
    }

    return true;
  }

  Future<void> _obtenerUbicacion({bool moverCamara = true}) async {
    final ok = await _asegurarPermisosYServicio();
    if (!ok) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final current = LatLng(pos.latitude, pos.longitude);
    setState(() => _miUbicacion = current);

    if (moverCamara) {
      _mapController.move(current, 16);
    }
  }

  // ======================
  // 2) Ruta (OSRM)
  // ======================
  Future<void> _calcularRuta() async {
    if (_cargandoRuta) return;

    // Asegura ubicación primero
    if (_miUbicacion == null) {
      await _obtenerUbicacion(moverCamara: false);
      if (_miUbicacion == null) {
        _snack('No tengo tu ubicación. En emulador: ⋮ → Location → Send');
        return;
      }
    }

    setState(() => _cargandoRuta = true);

    // OSRM usa lon,lat (en ese orden)
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${_miUbicacion!.longitude},${_miUbicacion!.latitude};'
      '${destino.longitude},${destino.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final res = await http.get(
        url,
        headers: {'User-Agent': 'com.example.restcampo (flutter)'},
      );

      if (res.statusCode != 200) {
        _snack('No se pudo calcular ruta (${res.statusCode})');
        return;
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = (data['routes'] as List?) ?? [];
      if (routes.isEmpty) {
        _snack('No hay rutas disponibles');
        return;
      }

      final geometry = routes.first['geometry'] as Map<String, dynamic>;
      final coords = (geometry['coordinates'] as List);

      final points = coords
          .map(
            (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
          )
          .toList();

      if (points.length < 2) {
        _snack('Ruta inválida (muy pocos puntos)');
        return;
      }

      setState(() => _ruta = points);

      // Ajusta cámara para ver toda la ruta
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
      );

      _snack('Ruta lista ✅');
    } catch (e) {
      _snack('Error calculando la ruta');
    } finally {
      if (mounted) setState(() => _cargandoRuta = false);
    }
  }

  void _limpiarRuta() => setState(() => _ruta = []);

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Mapa'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            tooltip: 'Ruta',
            onPressed: _cargandoRuta ? null : _calcularRuta,
            icon: _cargandoRuta
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.alt_route),
          ),
          IconButton(
            tooltip: 'Limpiar',
            onPressed: _limpiarRuta,
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: destino,
              initialZoom: 16,
              minZoom: 1,
              maxZoom: 19,
            ),
            children: [
              // Mapa base (evita tile.openstreetmap.org para no 403)
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.restcampo',
                maxZoom: 19,
              ),

              // Ruta (línea)
              if (_ruta.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _ruta,
                      strokeWidth: 6,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),

              // Marcador del destino
              const MarkerLayer(
                markers: [
                  Marker(
                    point: destino,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.location_on, color: Colors.red, size: 34),
                  ),
                ],
              ),

              // Ubicación actual (sin mover el mapa solo)
              CurrentLocationLayer(
                alignPositionOnUpdate: AlignOnUpdate.never,
                alignDirectionOnUpdate: AlignOnUpdate.never,
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.location_pin,
                      color: isDark ? Colors.white : Colors.blue,
                    ),
                  ),
                  markerSize: const Size(35, 35),
                ),
              ),
            ],
          ),

          // Zoom +/-
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _zoomButton(Icons.add, _zoomIn),
                const SizedBox(height: 10),
                _zoomButton(Icons.remove, _zoomOut),
              ],
            ),
          ),

          // Botón mi ubicación
          Positioned(
            right: 16,
            bottom: 40,
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () => _obtenerUbicacion(moverCamara: true),
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
