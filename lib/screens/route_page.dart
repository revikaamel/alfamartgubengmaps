import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class RoutePage extends StatefulWidget {

  final Map place;
  final LatLng currentLocation;

  const RoutePage({
    super.key,
    required this.place,
    required this.currentLocation,
  });

  @override
  State<RoutePage> createState() =>
      _RoutePageState();
}

class _RoutePageState
    extends State<RoutePage> {

  String vehicle = "Motor";

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

  String getEstimatedTime(
      double distanceKm) {

    double speed = getSpeed();

    double hours =
        distanceKm / speed;

    int minutes =
        (hours * 60).round();

    if (minutes <= 0) {
      minutes = 1;
    }

    return "$minutes menit";
  }

  @override
  Widget build(BuildContext context) {

    double distanceInMeters =
        Geolocator.distanceBetween(

      widget.currentLocation.latitude,
      widget.currentLocation.longitude,

      widget.place['lat'],
      widget.place['lng'],
    );

    double distanceKm =
        distanceInMeters / 1000;

    String estimation =
        getEstimatedTime(distanceKm);

    return Scaffold(

      appBar: AppBar(
        title: const Text("Rute"),
      ),

      body: Column(

        children: [

          Expanded(

            child: FlutterMap(

              options: MapOptions(

                initialCenter:
                    widget.currentLocation,

                initialZoom: 15,
              ),

              children: [

                TileLayer(

                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),

                PolylineLayer(

                  polylines: [

                    Polyline(

                      points: [

                        widget.currentLocation,

                        LatLng(
                          widget.place['lat'],
                          widget.place['lng'],
                        )
                      ],

                      strokeWidth: 6,

                      color: Colors.red,
                    )
                  ],
                ),

                MarkerLayer(

                  markers: [

                    Marker(

                      point:
                          widget.currentLocation,

                      width: 80,
                      height: 80,

                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),

                    Marker(

                      point: LatLng(
                        widget.place['lat'],
                        widget.place['lng'],
                      ),

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
              ],
            ),
          ),

          Container(

            padding:
                const EdgeInsets.all(15),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                DropdownButton<String>(

                  value: vehicle,

                  isExpanded: true,

                  items: [

                    "Mobil",
                    "Motor",
                    "Sepeda",
                    "Jalan Kaki"

                  ].map((item) {

                    return DropdownMenuItem(

                      value: item,

                      child: Text(item),
                    );
                  }).toList(),

                  onChanged: (value) {

                    setState(() {

                      vehicle = value!;
                    });
                  },
                ),

                const SizedBox(height: 10),

                Text(
                  "Jarak : ${distanceKm.toStringAsFixed(1)} km",
                ),

                Text(
                  "Estimasi : $estimation",
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}