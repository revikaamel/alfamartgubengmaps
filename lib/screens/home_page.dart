import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../admin/admin_page.dart';
import '../services/api_service.dart';
import 'detail_page.dart';
import 'saved_page.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {

  LatLng currentLocation =
      LatLng(-7.265, 112.752);

  String search = "";

  String filterType = "default";

  List places = [];

  bool isLoading = true;

  Future<void> getLocation() async {

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled =
        await Geolocator
            .isLocationServiceEnabled();

    if (!serviceEnabled) return;

    permission =
        await Geolocator
            .checkPermission();

    if (permission ==
        LocationPermission.denied) {

      permission =
          await Geolocator
              .requestPermission();
    }

    Position position =
        await Geolocator
            .getCurrentPosition();

    setState(() {

      currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );
    });
  }

  Future<void> fetchPlaces() async {

    try {

      final data =
          await ApiService
              .getPlaces();

      setState(() {

        places = data;

        isLoading = false;
      });

    } catch (e) {

      print(e);

      setState(() {

        isLoading = false;
      });
    }
  }

  double toDouble(dynamic value) {

    return double.tryParse(
      value.toString(),
    ) ?? 0;
  }

  double calculateDistance(
    double lat,
    double lng,
  ) {

    return Geolocator
        .distanceBetween(

      currentLocation.latitude,
      currentLocation.longitude,

      lat,
      lng,
    );
  }

  String getPhotoPath(String photo) {

    if (photo.contains(".")) {

      return "assets/images/$photo";
    }

    return "assets/images/$photo.png";
  }

  @override
  void initState() {

    super.initState();

    getLocation();

    fetchPlaces();
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(

        body: Center(

          child:
              CircularProgressIndicator(),
        ),
      );
    }

    List filteredPlaces =
        places.where((place) {

      return place['name']
          .toString()
          .toLowerCase()
          .contains(
            search.toLowerCase(),
          );

    }).toList();

    if (filterType == "rating") {

      filteredPlaces.sort(

        (a, b) =>

            toDouble(b['rating'])
                .compareTo(

              toDouble(a['rating']),
            ),
      );
    }

    if (filterType == "distance") {

      filteredPlaces.sort((a, b) {

        double distanceA =
            calculateDistance(

          toDouble(a['lat']),
          toDouble(a['lng']),
        );

        double distanceB =
            calculateDistance(

          toDouble(b['lat']),
          toDouble(b['lng']),
        );

        return distanceA.compareTo(
          distanceB,
        );
      });
    }

    if (filterType == "farthest") {

      filteredPlaces.sort((a, b) {

        double distanceA =
            calculateDistance(

          toDouble(a['lat']),
          toDouble(a['lng']),
        );

        double distanceB =
            calculateDistance(

          toDouble(b['lat']),
          toDouble(b['lng']),
        );

        return distanceB.compareTo(
          distanceA,
        );
      });
    }

    return Scaffold(

      body: Stack(

        children: [

          FlutterMap(

            options: MapOptions(

              initialCenter:
                  currentLocation,

              initialZoom: 15,
            ),

            children: [

              TileLayer(

                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),

              MarkerLayer(

                markers: [

                  Marker(

                    point:
                        currentLocation,

                    width: 80,
                    height: 80,

                    child: const Icon(

                      Icons.my_location,

                      color:
                          Colors.blue,

                      size: 40,
                    ),
                  ),

                  ...filteredPlaces.map(
                      (place) {

                    return Marker(

                      point: LatLng(

                        toDouble(
                            place['lat']),

                        toDouble(
                            place['lng']),
                      ),

                      width: 80,
                      height: 80,

                      child:
                          GestureDetector(

                        onTap: () {

                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder: (_) =>
                                  DetailPage(

                                place: place,

                                currentLocation:
                                    currentLocation,
                              ),
                            ),
                          );
                        },

                        child: const Icon(

                          Icons.location_on,

                          color:
                              Colors.red,

                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),

          Positioned(

            top: 50,
            left: 15,
            right: 15,

            child: Row(

              children: [

                Expanded(

                  child: TextField(

                    decoration:
                        InputDecoration(

                      filled: true,

                      fillColor:
                          Colors.white,

                      hintText:
                          "Cari Alfamart",

                      prefixIcon:
                          const Icon(
                        Icons.search,
                      ),

                      border:
                          OutlineInputBorder(

                        borderRadius:
                            BorderRadius
                                .circular(
                                    30),

                        borderSide:
                            BorderSide.none,
                      ),
                    ),

                    onChanged: (value) {

                      setState(() {

                        search = value;
                      });
                    },
                  ),
                ),

                const SizedBox(
                    width: 10),

                Container(

                  decoration:
                      BoxDecoration(

                    color:
                        Colors.white,

                    borderRadius:
                        BorderRadius
                            .circular(
                                15),
                  ),

                  child: IconButton(

                    icon: const Icon(
                      Icons.tune,
                    ),

                    onPressed: () {

                      showModalBottomSheet(

                        context: context,

                        builder: (_) {

                          return Column(

                            mainAxisSize:
                                MainAxisSize
                                    .min,

                            children: [

                              ListTile(

                                title:
                                    const Text(
                                  "Rating Tertinggi",
                                ),

                                onTap: () {

                                  setState(() {

                                    filterType =
                                        "rating";
                                  });

                                  Navigator.pop(
                                      context);
                                },
                              ),

                              ListTile(

                                title:
                                    const Text(
                                  "Terdekat",
                                ),

                                onTap: () {

                                  setState(() {

                                    filterType =
                                        "distance";
                                  });

                                  Navigator.pop(
                                      context);
                                },
                              ),

                              ListTile(

                                title:
                                    const Text(
                                  "Terjauh",
                                ),

                                onTap: () {

                                  setState(() {

                                    filterType =
                                        "farthest";
                                  });

                                  Navigator.pop(
                                      context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}