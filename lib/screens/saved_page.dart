import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../data/places.dart';
import 'detail_page.dart';

class SavedPage extends StatefulWidget {

  const SavedPage({super.key});

  @override
  State<SavedPage> createState() =>
      _SavedPageState();
}

class _SavedPageState
    extends State<SavedPage> {

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

                  child: ListTile(

                    title: Text(
                      place['name'],
                    ),

                    subtitle: Text(
                      place['address'],
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
                      ).then((_) {

                        setState(() {});
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}