import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../admin/admin_page.dart';
import '../data/places.dart';
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

  final MapController
      mapController =
      MapController();

  LatLng currentLocation =
      LatLng(-7.265, 112.752);

  String search = "";

  String filterType = "default";

  bool isLoading = true;
  bool mapReady = false;

  double toDouble(dynamic value) {

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

 @override
void initState() {
  super.initState();

  loadData();
  getLocation();

  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  ).listen((Position position) {

    setState(() {

      currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );
    });
  });
}
Future<void> loadData() async {

  try {

    print("LOAD DATA DIMULAI");

    final data =
        await ApiService.getPlaces();

    print("DATA DARI API:");
    print(data);

    print("JUMLAH DATA:");
    print(data.length);

    setState(() {

      places.clear();

      places.addAll(data);

      isLoading = false;
    });

    print("PLACES:");
    print(places.length);

  } catch (e) {

    print("ERROR LOAD DATA:");
    print(e);

    setState(() {

      isLoading = false;
    });
  }
}

  Future<void> getLocation() async {

    try {

      bool serviceEnabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission =
          await Geolocator
              .checkPermission();

      if (permission ==
          LocationPermission.denied) {

        permission =
            await Geolocator
                .requestPermission();
      }

      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {

        return;
      }

      Position position =
          await Geolocator
              .getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high,
      );

      currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {});

      if (mapReady) {

        mapController.move(
          currentLocation,
          15,
        );
      }

    } catch (e) {

      print(e);
    }
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

  String getPhotoPath(
      String photo) {

    if (photo.contains(
        "assets/images/")) {

      return photo;
    }

    return "assets/images/$photo";
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

            toDouble(
              b['rating'],
            ).compareTo(

              toDouble(
                a['rating'],
              ),
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

            mapController:
                mapController,

            options: MapOptions(

              initialCenter:
                  currentLocation,

              initialZoom: 15,

              onMapReady: () {

                mapReady = true;

                mapController.move(
                  currentLocation,
                  15,
                );
              },
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
                          place['lat'],
                        ),

                        toDouble(
                          place['lng'],
                        ),
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

                                place:
                                    place,
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

                const SizedBox(
                    width: 10),

                GestureDetector(

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const AdminPage(),
                      ),
                    ).then((_) {

                      setState(() {});
                    });
                  },

                  child: Container(

                    width: 50,
                    height: 50,

                    decoration:
                        const BoxDecoration(

                      color:
                          Colors.white,

                      shape:
                          BoxShape.circle,
                    ),

                    child: const Icon(

                      Icons
                          .admin_panel_settings,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(

            bottom: 0,
            left: 0,
            right: 0,

            child: Container(

              height: 320,

              decoration:
                  const BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.only(

                  topLeft:
                      Radius.circular(25),

                  topRight:
                      Radius.circular(25),
                ),
              ),

              child: Column(

                children: [

                  Expanded(

                    child:
                        ListView.builder(

                      itemCount:
                          filteredPlaces
                              .length,

                      itemBuilder:
                          (context,
                              index) {

                        var place =
                            filteredPlaces[
                                index];

                        double distance =
                            calculateDistance(

                          toDouble(
                              place['lat']),

                          toDouble(
                              place['lng']),
                        );

                        return ListTile(

                          leading:
                              CircleAvatar(

                            backgroundImage:

                                place['photo']
                                        .toString()
                                        .startsWith("/")

                                    ? FileImage(
                                        File(
                                          place['photo'],
                                        ),
                                      )

                                    : AssetImage(

                                        getPhotoPath(
                                          place['photo'],
                                        ),
                                      ) as ImageProvider,
                          ),

                          title: Text(
                            place['name'],
                          ),

                          subtitle: Text(

                            "⭐ ${place['rating']} • "
                            "${(distance / 1000).toStringAsFixed(1)} km",
                          ),

                          trailing:
                              IconButton(

                            icon:
                                const Icon(
                              Icons.route,
                            ),

                            onPressed:
                                () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>
                                      DetailPage(

                                    place:
                                        place,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(

                    padding:
                        const EdgeInsets
                            .all(15),

                    child: SizedBox(

                      width:
                          double.infinity,

                      height: 50,

                      child:
                          ElevatedButton
                              .icon(

                        icon: const Icon(
                          Icons.bookmark,
                        ),

                        label: const Text(
                          "Tersimpan",
                        ),

                        onPressed: () {

                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder: (_) =>
                                  const SavedPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}