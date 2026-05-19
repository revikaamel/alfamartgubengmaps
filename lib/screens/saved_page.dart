import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../data/places.dart';
import 'detail_page.dart';

class SavedPage extends StatelessWidget {

  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Tempat Tersimpan",
        ),
      ),

      body: savedPlaces.isEmpty

          ? const Center(

              child: Text(
                "Belum ada tempat tersimpan",
              ),
            )

          : ListView.builder(

              itemCount: savedPlaces.length,

              itemBuilder: (context, index) {

                var place =
                    savedPlaces[index];

                return Card(

                  margin:
                      const EdgeInsets.all(10),

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                            18),
                  ),

                  child: ListTile(

                    contentPadding:
                        const EdgeInsets.symmetric(

                      horizontal: 15,
                      vertical: 10,
                    ),

                    leading: CircleAvatar(

                      radius: 28,

                      backgroundImage:
                          AssetImage(
                        'assets/images/${place['photo']}',
                      ),
                    ),

                    title: Text(

                      place['name'],

                      style: const TextStyle(

                        fontWeight:
                            FontWeight.bold,

                        fontSize: 16,
                      ),
                    ),

                    subtitle: Padding(

                      padding:
                          const EdgeInsets.only(
                              top: 5),

                      child: Text(
                        place['address'],
                      ),
                    ),

                    trailing: const Icon(

                      Icons.arrow_forward_ios,

                      size: 18,
                    ),

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              DetailPage(

                            place: place,

                            currentLocation:
                                LatLng(
                              -7.265,
                              112.752,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}