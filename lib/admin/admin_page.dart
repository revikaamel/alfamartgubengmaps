import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Admin Direktori"),
      ),

      floatingActionButton:
          FloatingActionButton(

        child: const Icon(Icons.add),

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

      body: ListView.builder(

        itemCount: places.length,

        itemBuilder: (context, index) {

          var place = places[index];

          return Card(

            margin:
                const EdgeInsets.all(10),

            child: ListTile(

              leading: CircleAvatar(

                backgroundImage:
                    AssetImage(
                  place['photo'],
                ),
              ),

              title: Text(place['name']),

              subtitle:
                  Text(place['address']),

              trailing: Row(

                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  IconButton(

                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),

                    onPressed: () async {

                      await Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              EditPlacePage(
                            place: place,
                          ),
                        ),
                      );

                      setState(() {});
                    },
                  ),

                  IconButton(

                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),

                    onPressed: () {

                      setState(() {

                        places.removeAt(index);
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