import 'package:flutter/material.dart';
import 'dart:io';
import '../data/places.dart';
import 'add_place_page.dart';
import 'edit_place_page.dart';

class AdminPage extends StatefulWidget {

  const AdminPage({super.key});

  @override
  State<AdminPage> createState() =>
      _AdminPageState();
}

class _AdminPageState
    extends State<AdminPage> {

  String getPhotoPath(String photo) {

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
          "Admin Direktori",
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        child: const Icon(
          Icons.add,
        ),

        onPressed: () async {

          await Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const AddPlacePage(),
            ),
          );

          setState(() {});
        },
      ),

      body: places.isEmpty

          ? const Center(

              child: Text(
                "Belum ada data",
              ),
            )

          : ListView.builder(

              itemCount:
                  places.length,

              itemBuilder:
                  (context, index) {

                var place =
                    places[index];

                return Card(

                  margin:
                      const EdgeInsets
                          .all(10),

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

                    trailing: Row(

                      mainAxisSize:
                          MainAxisSize
                              .min,

                      children: [

                        IconButton(

                          icon:
                              const Icon(

                            Icons.edit,

                            color:
                                Colors
                                    .blue,
                          ),

                          onPressed:
                              () async {

                            await Navigator
                                .push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    EditPlacePage(

                                  place:
                                      place,
                                ),
                              ),
                            );

                            setState(
                                () {});
                          },
                        ),

                        IconButton(

                          icon:
                              const Icon(

                            Icons.delete,

                            color:
                                Colors
                                    .red,
                          ),

                          onPressed:
                              () {

                            setState(() {

                              places.removeAt(
                                  index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}