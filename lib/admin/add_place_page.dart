import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

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

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  final photoController = TextEditingController();

  bool _isLoading = false;

  double toDouble(String value) {
    return double.tryParse(value) ?? 0;
  }

  Future<void> savePlace() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tempat tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final place = {
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'lat': toDouble(latController.text),
        'lng': toDouble(lngController.text),
        'photo': photoController.text.trim(),
        'rating': 0.0,
        'reviews': [],
      };

      await SupabaseService.addPlace(place);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
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
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : savePlace,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

