import 'package:flutter/material.dart';

import '../data/places.dart';
import 'detail_page.dart';

class SavedPage extends StatelessWidget {

  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Tempat Tersimpan"),
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

                var place = savedPlaces[index];

                return Card(

                  margin: const EdgeInsets.all(10),

                  child: ListTile(

                    leading: CircleAvatar(
                      backgroundImage:
                          AssetImage(place['photo']),
                    ),

                    title: Text(place['name']),

                    subtitle:
                        Text(place['address']),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                    ),

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) => DetailPage(
                            place: place,
                            currentLocation:
                                place['currentLocation'],
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