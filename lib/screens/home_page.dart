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

  LatLng currentLocation = LatLng(-7.265, 112.752);

  String search = '';
  String filterType = 'default';

  bool isLoading = true;
  bool mapReady = false;
  bool _isAdmin = false;

  double toDouble(dynamic value) {
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    loadData();
    _checkAdmin();
    getLocation();

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  Future<void> _checkAdmin() async {
    final admin = await SupabaseService.isAdmin();
    if (mounted) setState(() => _isAdmin = admin);
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

  Future<void> getLocation() async {
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLocation = LatLng(position.latitude, position.longitude);
      setState(() {});

      if (mapReady) mapController.move(currentLocation, 15);
    } catch (e) {
      debugPrint('ERROR LOCATION: $e');
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout',
                style: TextStyle(color: Color(0xFFD32F2F))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await SupabaseService.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
        double distA = calculateDistance(toDouble(a['lat']), toDouble(a['lng']));
        double distB = calculateDistance(toDouble(b['lat']), toDouble(b['lng']));
        return distA.compareTo(distB);
      });
    }

    if (filterType == 'farthest') {
      filteredPlaces.sort((a, b) {
        double distA = calculateDistance(toDouble(a['lat']), toDouble(a['lng']));
        double distB = calculateDistance(toDouble(b['lat']), toDouble(b['lng']));
        return distB.compareTo(distA);
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation,
              initialZoom: 15,
              onMapReady: () {
                mapReady = true;
                mapController.move(currentLocation, 15);
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
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                  ...filteredPlaces.map((place) {
                    return Marker(
                      point: LatLng(toDouble(place['lat']), toDouble(place['lng'])),
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(place: place),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // ── Top bar ──────────────────────────────────────────────────────
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Row(
              children: [
                // Search box
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Cari Alfamart',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => setState(() => search = value),
                  ),
                ),

                const SizedBox(width: 10),

                // Filter
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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

                const SizedBox(width: 10),

                // Logout button
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded,
                        color: Color(0xFFD32F2F)),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom list ───────────────────────────────────────────────────
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
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
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
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.bookmark),
                        label: const Text('Tersimpan'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SavedPage(),
                            ),
                          );
                        },
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
}
