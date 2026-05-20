import 'package:flutter/material.dart';

import '../data/places.dart';

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

        title:
            const Text(
          "Admin Direktori",
        ),
      ),

      body: ListView.builder(

        itemCount: places.length,

        itemBuilder:
            (context, index) {

          var place =
              places[index];

          return Card(

            margin:
                const EdgeInsets.all(
                    10),

            child: ListTile(

              leading:
                  CircleAvatar(

                backgroundImage:
                    AssetImage(
                  "assets/images/${place['photo']}",
                ),
              ),

              title: Text(
                place['name']
                    .toString(),
              ),

              subtitle: Text(
                place['address']
                    .toString(),
              ),

              trailing: Text(
                "⭐ ${place['rating']}",
              ),
            ),
          );
        },
      ),
    );
  }
}