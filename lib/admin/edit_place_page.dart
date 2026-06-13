import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class EditPlacePage extends StatefulWidget {
  final Map place;

  const EditPlacePage({
    super.key,
    required this.place,
  });

  @override
  State<EditPlacePage> createState() => _EditPlacePageState();
}

class _EditPlacePageState extends State<EditPlacePage> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController latController;
  late TextEditingController lngController;
  late TextEditingController photoController;

  bool _isLoading = false;

  double toDouble(String value) {
    return double.tryParse(value) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.place['name']?.toString());
    addressController = TextEditingController(text: widget.place['address']?.toString());
    latController = TextEditingController(text: widget.place['lat']?.toString());
    lngController = TextEditingController(text: widget.place['lng']?.toString());
    photoController = TextEditingController(text: widget.place['photo']?.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    latController.dispose();
    lngController.dispose();
    photoController.dispose();
    super.dispose();
  }

  Future<void> updatePlace() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tempat tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'lat': toDouble(latController.text),
        'lng': toDouble(lngController.text),
        'photo': photoController.text.trim(),
      };

      await SupabaseService.updatePlace(widget.place['id'], data);

      // Update local map agar tampilan langsung berubah tanpa perlu reload
      widget.place['name'] = data['name'];
      widget.place['address'] = data['address'];
      widget.place['lat'] = data['lat'];
      widget.place['lng'] = data['lng'];
      widget.place['photo'] = data['photo'];

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengupdate: $e')),
      );
    }
  }

  Widget buildField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Tempat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildField('Nama Tempat', nameController),
            buildField('Alamat', addressController),
            buildField('Latitude', latController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true)),
            buildField('Longitude', lngController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true)),
            buildField('Nama Foto (contoh: alfamart.jpg)', photoController),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : updatePlace,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
