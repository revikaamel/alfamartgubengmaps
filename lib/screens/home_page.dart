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
import 'profile_page.dart';

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
  bool _isLoggedIn = false;
  bool _locationReady = false;
  int _navIndex = 0;

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
      final admin = await SupabaseService.isAdmin();
      if (mounted) {
        setState(() {
          _isLoggedIn = true;
          _isAdmin = admin;
        });
      }
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
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
          _locationReady = true;
        });
        if (mapReady) mapController.move(currentLocation, 15);
      }

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
        ),
      );
    }

    List filteredPlaces = places.where((place) {
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
        double distA =
            calculateDistance(toDouble(a['lat']), toDouble(a['lng']));
        double distB =
            calculateDistance(toDouble(b['lat']), toDouble(b['lng']));
        return distA.compareTo(distB);
      });
    }
    if (filterType == 'farthest') {
      filteredPlaces.sort((a, b) {
        double distA =
            calculateDistance(toDouble(a['lat']), toDouble(a['lng']));
        double distB =
            calculateDistance(toDouble(b['lat']), toDouble(b['lng']));
        return distB.compareTo(distA);
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── PETA ──────────────────────────────────────────────────────────
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
                  // Lokasi user
                  Marker(
                    point: currentLocation,
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.circle, color: Colors.blue, size: 20),
                      ),
                    ),
                  ),
                  // Marker Alfamart
                  ...filteredPlaces.map((place) {
                    return Marker(
                      point: LatLng(
                        toDouble(place['lat']),
                        toDouble(place['lng']),
                      ),
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
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
                                color: Colors.black.withValues(alpha: 0.2),
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

          // ── TOP BAR ───────────────────────────────────────────────────────
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Row(
              children: [
                // Search box
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: (value) => setState(() => search = value),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Filter button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('Rating Tertinggi'),
                              leading: const Icon(Icons.star_rounded,
                                  color: Colors.amber),
                              onTap: () {
                                setState(() => filterType = 'rating');
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('Terdekat'),
                              leading: const Icon(Icons.near_me_rounded,
                                  color: Colors.blue),
                              onTap: () {
                                setState(() => filterType = 'distance');
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('Terjauh'),
                              leading: const Icon(Icons.explore_rounded,
                                  color: Colors.green),
                              onTap: () {
                                setState(() => filterType = 'farthest');
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Admin button (hanya tampil jika admin)
                if (_isAdmin) ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminPage()),
                      ).then((_) => loadData());
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.admin_panel_settings),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Bottom list (hanya muncul saat ada pencarian) ─────────────────
          if (search.isNotEmpty)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Container(
                height: 260,
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
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    var place = filteredPlaces[index];
                    double distance = calculateDistance(
                      toDouble(place['lat']),
                      toDouble(place['lng']),
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            place['photo'].toString().startsWith('/')
                                ? FileImage(File(place['photo']))
                                : AssetImage(getPhotoPath(place['photo']))
                                    as ImageProvider,
                      ),
                      title: Text(place['name']),
                      subtitle: Text(
                        '⭐ ${place['rating']} • '
                        '${(distance / 1000).toStringAsFixed(1)} km',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.route),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(place: place),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

          // ── Floating Bottom Nav ───────────────────────────────────────────
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Peta
                  _NavItem(
                    icon: Icons.map_rounded,
                    label: 'Peta',
                    selected: _navIndex == 0,
                    onTap: () => setState(() => _navIndex = 0),
                  ),

                  // Tersimpan
                  _NavItem(
                    icon: Icons.bookmark_rounded,
                    label: 'Tersimpan',
                    selected: _navIndex == 1,
                    onTap: () {
                      setState(() => _navIndex = 1);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedPage(),
                        ),
                      ).then((_) => setState(() => _navIndex = 0));
                    },
                  ),

                  // Profil
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profil',
                    selected: _navIndex == 2,
                    onTap: () {
                      setState(() => _navIndex = 2);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfilePage(),
                        ),
                      ).then((_) {
                        if (mounted) {
                          setState(() => _navIndex = 0);
                          _checkLoginStatus();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widget nav item ────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFD32F2F);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? red.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: selected ? red : Colors.grey.shade500,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? red : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
