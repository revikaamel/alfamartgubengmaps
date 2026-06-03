import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../data/places.dart';

class AddPlacePage extends StatefulWidget {

  const AddPlacePage({
    super.key,
  });

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

  double toDouble(
    String value,
  ) {

    return double.tryParse(
          value,
        ) ??
        0;
  }

 Future<void> savePlace() async {

  Map<String, dynamic> place = {

    "id":
        DateTime.now()
            .millisecondsSinceEpoch,

    "name":
        nameController.text,

    "address":
        addressController.text,

    "lat":
        toDouble(
          latController.text,
        ),

    "lng":
        toDouble(
          lngController.text,
        ),

    "photo":
        photoController.text,

    "rating": 0,

    "reviews": ""
  };

  await ApiService.addPlace(
    place,
  );

  Navigator.pop(
    context,
    true,
  );
}

  Widget buildField(
    String label,
    TextEditingController
        controller,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),

      child: TextField(

        controller:
            controller,

        decoration:
            InputDecoration(

          labelText: label,

          border:
              OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
              15,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Tambah Tempat",
        ),
      ),

      body:
          SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          children: [

            buildField(
              "Nama Tempat",
              nameController,
            ),

            buildField(
              "Alamat",
              addressController,
            ),

            buildField(
              "Latitude",
              latController,
            ),

            buildField(
              "Longitude",
              lngController,
            ),

            buildField(
              "Nama Foto (contoh: alfamart.jpg)",
              photoController,
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(

              width:
                  double.infinity,

              height: 50,

              child:
                  ElevatedButton(

                onPressed: () async {

                  await savePlace();
                },

                child:
                    const Text(
                  "Simpan",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

