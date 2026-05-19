import 'package:flutter/material.dart';

import '../data/places.dart';

class AddPlacePage extends StatefulWidget {

  const AddPlacePage({super.key});

  @override
  State<AddPlacePage> createState() =>
      _AddPlacePageState();
}

class _AddPlacePageState
    extends State<AddPlacePage> {

  final nameController =
      TextEditingController();

  final addressController =
      TextEditingController();

  final latController =
      TextEditingController();

  final lngController =
      TextEditingController();

  final photoController =
      TextEditingController();

  void savePlace() {

    places.add({

      "id": places.length + 1,

      "name": nameController.text,

      "address":
          addressController.text,

      "lat":
          double.parse(latController.text),

      "lng":
          double.parse(lngController.text),

      "photo": photoController.text,

      "rating": 0.0,

      "reviews": [],
    });

    Navigator.pop(context);
  }

  Widget buildField(
      String label,
      TextEditingController controller,
      ) {

    return Padding(

      padding:
          const EdgeInsets.only(bottom: 15),

      child: TextField(

        controller: controller,

        decoration: InputDecoration(

          labelText: label,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("Tambah Tempat"),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            buildField(
                "Nama Tempat",
                nameController),

            buildField(
                "Alamat",
                addressController),

            buildField(
                "Latitude",
                latController),

            buildField(
                "Longitude",
                lngController),

            buildField(
                "Photo Asset",
                photoController),

            SizedBox(

              width: double.infinity,

              height: 50,

              child: ElevatedButton(

                onPressed: savePlace,

                child:
                    const Text("Simpan"),
              ),
            )
          ],
        ),
      ),
    );
  }
}