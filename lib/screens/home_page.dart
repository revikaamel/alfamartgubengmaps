import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/supabase_service.dart';
import '../admin/admin_page.dart';
import '../data/places.dart';
import 'detail_page.dart';
import 'saved_page.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapController mapController = MapController();

  LatLng currentLocation = const LatLng(-7.2720, 112.7560);

  String search = '';
  String filterType = 'default';

  bool isLoading = true;
  bool mapReady = false;
  bool _isAdmin = false;
  bool _locationReady = false;
  bool _isLoggedIn = false;

  double toDouble(dynamic value) {
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    loadData();
    _checkLoginStatus();
    _initLocation();
  }

  Future<void> _checkLoginStatus() async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      setState(() => _isLoggedIn = true);
      final admin = await SupabaseService.isAdmin();
      if (mounted) setState(() => _isAdmin = admin);
    }
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        _locationReady = true;
      });

      if (mapReady) mapController.move(currentLocation, 15);

      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((pos) {
        if (mounted) {
          setState(() {
            currentLocation = LatLng(pos.latitude, pos.longitude);
          });
        }
      });
    } catch (e) {
      debugPrint('ERROR LOCATION: $e');
    }
  }

  Future<void> loadData() async {
    try {
      final data = await SupabaseService.getPlaces();
      setState(() {
        places.clear();
        places.addAll(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('ERROR LOAD DATA: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Logout Admin'),
            content: const Text('Yakin ingin keluar dari akun admin?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Color(0xFFD32F2F)),
                ),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    await SupabaseService.signOut();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = false;
      _isAdmin = false;
    });
  }

  double calculateDistance(double lat, double lng) {
    return Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      lat,
      lng,
    );
  }

  String getPhotoPath(String photo) {
    if (photo.contains('assets/images/')) return photo;
    return 'assets/images/$photo';
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                title: const Text('Rating Tertinggi'),
                leading: const Icon(Icons.star_rounded, color: Colors.amber),
                onTap: () {
                  setState(() => filterType = 'rating');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Terdekat'),
                leading: const Icon(Icons.near_me_rounded, color: Colors.blue),
                onTap: () {
                  setState(() => filterType = 'distance');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Terjauh'),
                leading: const Icon(Icons.explore_rounded, color: Colors.green),
                onTap: () {
                  setState(() => filterType = 'farthest');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Default'),
                leading: const Icon(Icons.sort, color: Colors.grey),
                onTap: () {
                  setState(() => filterType = 'default');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
    );
  }

  void _openAdminAccess() {
    if (_isLoggedIn && _isAdmin) {
      // Sudah login sebagai admin → langsung ke admin page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      ).then((_) => loadData());
    } else {
      // Belum login → buka login screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ).then((_) => _checkLoginStatus());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
        ),
      );
    }

    List filteredPlaces =
        places.where((place) {
          return place['name'].toString().toLowerCase().contains(
            search.toLowerCase(),
          );
        }).toList();

    if (filterType == 'rating') {
      filteredPlaces.sort(
        (a, b) => toDouble(b['rating']).compareTo(toDouble(a['rating'])),
      );
    }
    if (filterType == 'distance') {
      filteredPlaces.sort((a, b) {
        double distA = calculateDistance(
          toDouble(a['lat']),
          toDouble(a['lng']),
        );
        double distB = calculateDistance(
          toDouble(b['lat']),
          toDouble(b['lng']),
        );
        return distA.compareTo(distB);
      });
    }
    if (filterType == 'farthest') {
      filteredPlaces.sort((a, b) {
        double distA = calculateDistance(
          toDouble(a['lat']),
          toDouble(a['lng']),
        );
        double distB = calculateDistance(
          toDouble(b['lat']),
          toDouble(b['lng']),
        );
        return distB.compareTo(distA);
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── PETA ──────────────────────────────────────────────────────
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation,
              initialZoom: 15,
              onMapReady: () {
                mapReady = true;
                if (_locationReady) {
                  mapController.move(currentLocation, 15);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.alfamart_gubeng_maps',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLocation,
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.circle, color: Colors.blue, size: 20),
                      ),
                    ),
                  ),
                  ...filteredPlaces.map((place) {
                    return Marker(
                      point: LatLng(
                        toDouble(place['lat']),
                        toDouble(place['lng']),
                      ),
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPage(place: place),
                              ),
                            ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD32F2F),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.store,
                            color: Color(0xFFD32F2F),
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // ── TOP BAR ───────────────────────────────────────────────────
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari Alfamart...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFD32F2F),
                        ),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                      onChanged: (value) => setState(() => search = value),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Tombol filter
                _topButton(icon: Icons.tune, onTap: _showFilterSheet),
                // Tombol logout (hanya muncul kalau sudah login)
                if (_isLoggedIn) ...[
                  const SizedBox(width: 8),
                  _topButton(
                    icon: Icons.logout_rounded,
                    color: const Color(0xFFD32F2F),
                    onTap: _logout,
                  ),
                ],
              ],
            ),
          ),

          // ── TOMBOL GPS ────────────────────────────────────────────────
          Positioned(
            right: 15,
            bottom: 340,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                if (mapReady) mapController.move(currentLocation, 15);
              },
              child: const Icon(Icons.my_location, color: Color(0xFFD32F2F)),
            ),
          ),

          // ── TOMBOL ADMIN (pojok kiri bawah, di atas bottom sheet) ──────
          Positioned(
            left: 15,
            bottom: 330,
            child: GestureDetector(
              onTap: _openAdminAccess,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _isAdmin ? const Color(0xFFD32F2F) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _isAdmin ? Icons.admin_panel_settings : Icons.lock_outline,
                  color: _isAdmin ? Colors.white : Colors.grey[400],
                  size: 18,
                ),
              ),
            ),
          ),

          // ── BOTTOM LIST ───────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 320,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        Text(
                          '${filteredPlaces.length} Alfamart ditemukan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        filteredPlaces.isEmpty
                            ? const Center(
                              child: Text(
                                'Tidak ada toko ditemukan',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                            : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: filteredPlaces.length,
                              separatorBuilder:
                                  (_, __) => Divider(
                                    height: 1,
                                    color: Colors.grey[200],
                                    indent: 16,
                                    endIndent: 16,
                                  ),
                              itemBuilder: (context, index) {
                                final place = filteredPlaces[index];
                                final distance = calculateDistance(
                                  toDouble(place['lat']),
                                  toDouble(place['lng']),
                                );
                                return ListTile(
                                  dense: true,
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        place['photo'].toString().startsWith(
                                              '/',
                                            )
                                            ? Image.file(
                                              File(place['photo']),
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                            )
                                            : Image.asset(
                                              getPhotoPath(place['photo']),
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) => Container(
                                                    width: 44,
                                                    height: 44,
                                                    color: const Color(
                                                      0xFFFFEBEE,
                                                    ),
                                                    child: const Icon(
                                                      Icons.store,
                                                      color: Color(0xFFD32F2F),
                                                    ),
                                                  ),
                                            ),
                                  ),
                                  title: Text(
                                    place['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '⭐ ${place['rating']} · '
                                    '${(distance / 1000).toStringAsFixed(1)} km',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: GestureDetector(
                                    onTap:
                                        () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => DetailPage(place: place),
                                          ),
                                        ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 14,
                                            color: Color(0xFF2E7D32),
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            'Detail',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF2E7D32),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => DetailPage(place: place),
                                        ),
                                      ),
                                );
                              },
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 4, 15, 15),
                    child: SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.bookmark, size: 18),
                        label: const Text('Tersimpan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SavedPage(),
                              ),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color ?? const Color(0xFF757575), size: 22),
      ),
    );
  }
}
