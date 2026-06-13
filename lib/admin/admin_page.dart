import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'add_place_page.dart';
import 'edit_place_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> _places = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.getPlaces();
      setState(() {
        _places = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _deletePlace(dynamic id, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Tempat'),
        content: const Text('Yakin ingin menghapus tempat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await SupabaseService.deletePlace(id);
      setState(() => _places.removeAt(index));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  String getPhotoPath(String photo) {
    if (photo.contains('assets/images/')) return photo;
    return 'assets/images/$photo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Direktori'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlaces,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPlacePage()),
          );
          if (result == true) {
            _loadPlaces();
          }
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _places.isEmpty
              ? const Center(child: Text('Belum ada data'))
              : ListView.builder(
                  itemCount: _places.length,
                  itemBuilder: (context, index) {
                    final place = _places[index];
                    final photo = place['photo']?.toString() ?? '';
                    final isNetwork = photo.startsWith('http');

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: isNetwork
                              ? NetworkImage(photo)
                              : AssetImage(getPhotoPath(photo)) as ImageProvider,
                          onBackgroundImageError: (_, __) {},
                          child: photo.isEmpty
                              ? const Icon(Icons.store)
                              : null,
                        ),
                        title: Text(place['name']?.toString() ?? '-'),
                        subtitle: Text(place['address']?.toString() ?? '-'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditPlacePage(place: place),
                                  ),
                                );
                                if (result == true) _loadPlaces();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deletePlace(place['id'], index),
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
