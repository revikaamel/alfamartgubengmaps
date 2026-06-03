import 'package:flutter/material.dart';

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

              itemCount:
                  savedPlaces.length,

              itemBuilder:
                  (context, index) {

                var place =
                    savedPlaces[index];

                return Card(

                  margin:
                      const EdgeInsets.all(
                    10,
                  ),

                  child: ListTile(

                    leading:
                        CircleAvatar(

                      backgroundImage:
                          AssetImage(

                        getPhotoPath(

                          place['photo']
                              .toString(),
                        ),
                      ),
                    ),

                    title: Text(
                      place['name']
                          .toString(),
                    ),

                    subtitle: Text(
                      place['address']
                              ?.toString() ??
                          "-",
                    ),

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