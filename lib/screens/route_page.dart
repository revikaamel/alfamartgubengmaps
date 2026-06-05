import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class RoutePage extends StatefulWidget {
  final Map place;

  const RoutePage({super.key, required this.place});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  final MapController mapController = MapController();

  LatLng currentLocation = LatLng(-7.265, 112.752);

  String vehicle = "Motor";

  List<LatLng> routePoints = [];

  bool isLoading = true;

  double toDouble(dynamic value) {
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();

    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;

    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    currentLocation = LatLng(position.latitude, position.longitude);

    await getRoute();
  }

  Future<void> getRoute() async {
    setState(() {
      isLoading = true;
    });

    try {
      String profile = "driving";

      if (vehicle == "Jalan Kaki") {
        profile = "foot";
      } else if (vehicle == "Sepeda") {
        profile = "cycling";
      }

      double lat = toDouble(widget.place['lat']);

      double lng = toDouble(widget.place['lng']);

      final url =
          "https://router.project-osrm.org/route/v1/"
          "$profile/"
          "${currentLocation.longitude},"
          "${currentLocation.latitude};"
          "$lng,"
          "$lat"
          "?overview=full&geometries=geojson";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final coordinates = data['routes'][0]['geometry']['coordinates'];

        List<LatLng> points = [];

        for (var point in coordinates) {
          points.add(LatLng(point[1].toDouble(), point[0].toDouble()));
        }

        setState(() {
          routePoints = points;

          isLoading = false;
        });

        if (routePoints.isNotEmpty) {
          mapController.move(currentLocation, 14);
        }
      }
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  double getDistance() {
    return Geolocator.distanceBetween(
      currentLocation.latitude,

      currentLocation.longitude,

      toDouble(widget.place['lat']),

      toDouble(widget.place['lng']),
    );
  }

  double getSpeed() {
    switch (vehicle) {
      case "Jalan Kaki":
        return 5;

      case "Sepeda":
        return 15;

      case "Mobil":
        return 30;

      default:
        return 40;
    }
  }

  String getEstimatedTime(double distanceKm) {
    double speed = getSpeed();

    double hours = distanceKm / speed;

    int minutes = (hours * 60).round();

    if (minutes <= 0) {
      minutes = 1;
    }

    return "$minutes menit";
  }

  @override
  Widget build(BuildContext context) {
    double distanceKm = getDistance() / 1000;

    String estimation = getEstimatedTime(distanceKm);

    double lat = toDouble(widget.place['lat']);

    double lng = toDouble(widget.place['lng']);

    return Scaffold(
      appBar: AppBar(title: const Text("Rute")),

      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,

              options: MapOptions(
                initialCenter: currentLocation,

                initialZoom: 14,
              ),

              children: [
                TileLayer(
                  urlTemplate:
                      'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.alfamart_gubeng_maps',
                ),

                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,

                      strokeWidth: 6,

                      color: Colors.red,
                    ),
                  ],
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

                    Marker(
                      point: LatLng(lat, lng),

                      width: 80,
                      height: 80,

                      child: const Icon(
                        Icons.location_on,

                        color: Colors.red,

                        size: 40,
                      ),
                    ),
                  ],
                ),

                if (isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(15),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                DropdownButton<String>(
                  value: vehicle,

                  isExpanded: true,

                  items:
                      ["Mobil", "Motor", "Sepeda", "Jalan Kaki"].map((item) {
                        return DropdownMenuItem(value: item, child: Text(item));
                      }).toList(),

                  onChanged: (value) async {
                    setState(() {
                      vehicle = value!;
                    });

                    await getRoute();
                  },
                ),

                const SizedBox(height: 10),

                Text(
                  "Jarak : "
                  "${distanceKm.toStringAsFixed(1)} km",
                ),

                Text(
                  "Estimasi : "
                  "$estimation",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
