import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

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

  LatLng currentLocation =
      LatLng(-7.265, 112.752);

  String search = "";

  String filterType = "default";

  Future<void> getLocation() async {

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled =
        await Geolocator
            .isLocationServiceEnabled();

    if (!serviceEnabled) return;

    permission =
        await Geolocator.checkPermission();

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

  double calculateDistance(
    double lat,
    double lng,
  ) {

    return Geolocator.distanceBetween(

      currentLocation.latitude,
      currentLocation.longitude,

      lat,
      lng,
    );
  }

  @override
  void initState() {

    super.initState();

    getLocation();
  }

  @override
  Widget build(BuildContext context) {

    List filteredPlaces =
        places.where((place) {

      return place['name']
          .toLowerCase()
          .contains(
            search.toLowerCase(),
          );

    }).toList();

    if (filterType == "rating") {

      filteredPlaces.sort(

        (a, b) =>
            b['rating']
                .compareTo(a['rating']),
      );
    }

    if (filterType == "distance") {

      filteredPlaces.sort((a, b) {

        double distanceA =
            calculateDistance(
          a['lat'],
          a['lng'],
        );

        double distanceB =
            calculateDistance(
          b['lat'],
          b['lng'],
        );

        return distanceA.compareTo(
          distanceB,
        );
      });
    }

    if (filterType == "reviews") {

      filteredPlaces.sort(

        (a, b) =>

            b['reviews'].length
                .compareTo(
              a['reviews'].length,
            ),
      );
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

                      point: LatLng(
                        place['lat'],
                        place['lng'],
                      ),

                      width: 80,
                      height: 80,

                      child: GestureDetector(

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

                          color: Colors.red,

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

                const SizedBox(width: 10),

                Container(

                  decoration: BoxDecoration(

                    color: Colors.white,

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

                                leading:
                                    const Icon(
                                  Icons.star,
                                ),

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

                                leading:
                                    const Icon(
                                  Icons.near_me,
                                ),

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

                                leading:
                                    const Icon(
                                  Icons.reviews,
                                ),

                                title:
                                    const Text(
                                  "Review Terbanyak",
                                ),

                                onTap: () {

                                  setState(() {

                                    filterType =
                                        "reviews";
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

                const SizedBox(width: 10),

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

                      color: Colors.white,

                      shape: BoxShape.circle,
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

                    child: ListView.builder(

                      itemCount:
                          filteredPlaces.length,

                      itemBuilder:
                          (context, index) {

                        var place =
                            filteredPlaces[index];

                        double distance =
                            calculateDistance(

                          place['lat'],
                          place['lng'],
                        );

                        return ListTile(

                          leading:
                              CircleAvatar(

                            backgroundImage:
                                AssetImage(
                              place['photo'],
                            ),
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

                            icon: const Icon(
                              Icons.route,
                            ),

                            onPressed: () {

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
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(

                    padding:
                        const EdgeInsets.all(
                            15),

                    child: SizedBox(

                      width: double.infinity,

                      height: 50,

                      child:
                          ElevatedButton.icon(

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