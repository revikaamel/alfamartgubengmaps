import 'package:flutter/material.dart';

class EditPlacePage extends StatefulWidget {

  final Map place;

  const EditPlacePage({
    super.key,
    required this.place,
  });

  @override
  State<EditPlacePage> createState() =>
      _EditPlacePageState();
}

class _EditPlacePageState
    extends State<EditPlacePage> {

  late TextEditingController
      nameController;

  late TextEditingController
      addressController;

  late TextEditingController
      latController;

  late TextEditingController
      lngController;

  late TextEditingController
      photoController;

  double toDouble(String value) {

    return double.tryParse(
          value,
        ) ??
        0;
  }

  @override
  void initState() {

    super.initState();

    nameController =
        TextEditingController(
      text: widget.place['name'],
    );

    addressController =
        TextEditingController(
      text:
          widget.place['address'],
    );

    latController =
        TextEditingController(
      text: widget.place['lat']
          .toString(),
    );

    lngController =
        TextEditingController(
      text: widget.place['lng']
          .toString(),
    );

    photoController =
        TextEditingController(
      text:
          widget.place['photo'],
    );
  }

  void updatePlace() {

    widget.place['name'] =
        nameController.text;

    widget.place['address'] =
        addressController.text;

    widget.place['lat'] =
        toDouble(
      latController.text,
    );

    widget.place['lng'] =
        toDouble(
      lngController.text,
    );

    widget.place['photo'] =
        photoController.text;

    Navigator.pop(context);
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
          "Edit Tempat",
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
              "Nama Foto",
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

                onPressed:
                    updatePlace,

                child:
                    const Text(
                  "Update",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

