import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  File? selectedImage;

  Future<void> pickImage() async {

    final picker = ImagePicker();

    final pickedFile =
        await picker.pickImage(

      source: ImageSource.gallery,
    );

    if (pickedFile != null) {

      setState(() {

        selectedImage =
            File(pickedFile.path);
      });
    }
  }

  double toDouble(String value) {

    return double.tryParse(value) ?? 0;
  }

  void savePlace() {

    places.add({

      "id": places.length + 1,

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

          selectedImage != null

              ? selectedImage!.path

              : "",

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
          const EdgeInsets.only(
        bottom: 15,
      ),

      child: TextField(

        controller: controller,

        decoration: InputDecoration(

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
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Tambah Tempat",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

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

            const SizedBox(
              height: 10,
            ),

            GestureDetector(

              onTap: pickImage,

              child: Container(

                width: double.infinity,

                height: 180,

                decoration: BoxDecoration(

                  border: Border.all(
                    color: Colors.grey,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),

                child:
                    selectedImage == null

                        ? const Column(

                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [

                              Icon(
                                Icons.image,
                                size: 50,
                              ),

                              SizedBox(
                                height: 10,
                              ),

                              Text(
                                "Pilih Foto",
                              ),
                            ],
                          )

                        : ClipRRect(

                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),

                            child: Image.file(

                              selectedImage!,

                              fit: BoxFit.cover,
                            ),
                          ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(

              width: double.infinity,

              height: 50,

              child: ElevatedButton(

                onPressed: savePlace,

                child: const Text(
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