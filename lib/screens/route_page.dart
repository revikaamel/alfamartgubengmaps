import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// ── Konfigurasi kendaraan ──────────────────────────────────────────────────
class _VehicleOption {
  final String label;
  final IconData icon;
  final String profile;
  final double speedKph;

  const _VehicleOption({
    required this.label,
    required this.icon,
    required this.profile,
    required this.speedKph,
  });
}

final List<_VehicleOption> _vehicles = [
  const _VehicleOption(label: 'Motor',      icon: Icons.two_wheeler,     profile: 'driving', speedKph: 40.0),
  const _VehicleOption(label: 'Mobil',      icon: Icons.directions_car,  profile: 'driving', speedKph: 30.0),
  const _VehicleOption(label: 'Sepeda',     icon: Icons.directions_bike, profile: 'cycling', speedKph: 15.0),
  const _VehicleOption(label: 'Jalan Kaki', icon: Icons.directions_walk, profile: 'foot',    speedKph: 5.0),
];

// ── Widget utama ──────────────────────────────────────────────────────────
class RoutePage extends StatefulWidget {
  final Map place;
  const RoutePage({super.key, required this.place});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage>
    with SingleTickerProviderStateMixin {
  static const Color _brandRed = Color(0xFFD32F2F);

  final MapController mapController = MapController();
  LatLng currentLocation = LatLng(-7.265, 112.752);

  int _selectedIndex = 0;
  List<LatLng> routePoints = [];
  bool isLoading = true;

  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  _VehicleOption get _currentVehicle => _vehicles[_selectedIndex];

  double toDouble(dynamic v) =>
      double.tryParse(v?.toString() ?? '') ?? 0.0;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _getCurrentLocation();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Lokasi ────────────────────────────────────────────────────────────────
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => isLoading = false);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      currentLocation = LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Location error: $e');
    }
    await _getRoute();
  }

  // ── Ambil rute OSRM ──────────────────────────────────────────────────────
  Future<void> _getRoute() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    _animCtrl.reset();

    try {
      final double lat = toDouble(widget.place['lat']);
      final double lng = toDouble(widget.place['lng']);
      final String profile = _currentVehicle.profile;

      final String url =
          'https://router.project-osrm.org/route/v1/$profile/'
          '${currentLocation.longitude},${currentLocation.latitude};'
          '$lng,$lat'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        final List<dynamic>? routes = data['routes'] as List<dynamic>?;

        if (routes != null && routes.isNotEmpty) {
          final List<dynamic> coordinates =
              (routes[0] as Map<String, dynamic>)['geometry']
                  ['coordinates'] as List<dynamic>;

          final List<LatLng> points = [];
          for (final dynamic p in coordinates) {
            final List<dynamic> coord = p as List<dynamic>;
            final double lon = (coord[0] as num).toDouble();
            final double latCoord = (coord[1] as num).toDouble();
            points.add(LatLng(latCoord, lon));
          }

          setState(() {
            routePoints = points;
            isLoading = false;
          });

          if (points.isNotEmpty) {
            mapController.move(currentLocation, 14.0);
          }

          _animCtrl.forward();
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Route error: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ── Pilih kendaraan ──────────────────────────────────────────────────────
  Future<void> _selectVehicle(int index) async {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    await _getRoute();
  }

  // ── Kalkulasi ────────────────────────────────────────────────────────────
  double get _distanceKm {
    return Geolocator.distanceBetween(
          currentLocation.latitude,
          currentLocation.longitude,
          toDouble(widget.place['lat']),
          toDouble(widget.place['lng']),
        ) /
        1000.0;
  }

  String get _estimatedTime {
    final double hours = _distanceKm / _currentVehicle.speedKph;
    final int minutes = (hours * 60.0).round();
    return '${minutes <= 0 ? 1 : minutes} menit';
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Peta ──────────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentLocation,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.alfamart_gubeng_maps',
                    ),
                    if (routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 5.0,
                            color: _brandRed,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        // Marker posisi saat ini
                        Marker(
                          point: currentLocation,
                          width: 44.0,
                          height: 44.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 3.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6.0,
                                  offset: Offset(0.0, 2.0),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 20.0,
                            ),
                          ),
                        ),
                        // Marker tujuan
                        Marker(
                          point: LatLng(
                            toDouble(widget.place['lat']),
                            toDouble(widget.place['lng']),
                          ),
                          width: 40.0,
                          height: 40.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _brandRed,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6.0,
                                  offset: Offset(0.0, 2.0),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.store_rounded,
                              color: Colors.white,
                              size: 20.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(color: _brandRed),
                      ),
                  ],
                ),

                // Tombol back custom
                Positioned(
                  top: 48.0,
                  left: 16.0,
                  child: _mapButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ),

                // Judul floating
                Positioned(
                  top: 48.0,
                  left: 72.0,
                  right: 16.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8.0,
                          offset: Offset(0.0, 2.0),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store_rounded,
                            color: _brandRed, size: 18.0),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            widget.place['name']?.toString() ?? 'Alfamart',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.0,
                              color: Color(0xFF212121),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Panel bawah ───────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16.0,
                  offset: Offset(0.0, -4.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    'Pilih Kendaraan',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // ── Vehicle selector ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0),
                  child: Row(
                    children: List.generate(
                      _vehicles.length,
                      (int i) => Expanded(
                        child: _VehicleChip(
                          option: _vehicles[i],
                          isSelected: _selectedIndex == i,
                          onTap: () => _selectVehicle(i),
                        ),
                      ),
                    ),
                  ),
                ),

                const Divider(height: 20.0, indent: 16.0, endIndent: 16.0),

                // ── Info jarak & estimasi ──────────────────────────────────
                SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 20.0),
                      child: Row(
                        children: [
                          _InfoCard(
                            icon: Icons.straighten_rounded,
                            label: 'Jarak',
                            value: '${_distanceKm.toStringAsFixed(1)} km',
                            color: _brandRed,
                          ),
                          const SizedBox(width: 12.0),
                          _InfoCard(
                            icon: Icons.access_time_rounded,
                            label: 'Estimasi',
                            value: _estimatedTime,
                            color: const Color(0xFF1565C0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.0,
        height: 44.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0.0, 2.0),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF212121), size: 22.0),
      ),
    );
  }
}

// ── Vehicle Chip ──────────────────────────────────────────────────────────
class _VehicleChip extends StatelessWidget {
  final _VehicleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _brandRed = Color(0xFFD32F2F);

  const _VehicleChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = _brandRed;
    final Color inactiveColor = const Color(0xFF9E9E9E);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: Icon(
                option.icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 26.0,
              ),
            ),
            const SizedBox(height: 5.0),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 280),
              style: TextStyle(
                fontSize: 11.0,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(
                option.label,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(icon, color: color, size: 22.0),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.0,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
