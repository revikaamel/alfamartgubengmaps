import 'dart:io';

import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import 'detail_page.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  static const Color _brandRed = Color(0xFFD32F2F);
  static const Color _brandRedLight = Color(0xFFEF5350);

  List<Map<String, dynamic>> _savedPlaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPlaces();
  }

  Future<void> _loadSavedPlaces() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.getSavedPlaces();
      setState(() {
        _savedPlaces = data;
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

  Future<void> _removePlace(Map<String, dynamic> place, int index) async {
    try {
      await SupabaseService.unsavePlace(place['id']);
      setState(() => _savedPlaces.removeAt(index));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${place['name']} dihapus dari tersimpan'),
            backgroundColor: _brandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'Urungkan',
              textColor: Colors.white,
              onPressed: () async {
                await SupabaseService.savePlace(place['id']);
                _loadSavedPlaces();
              },
            ),
          ),
        );
      }
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

  ImageProvider _getImageProvider(String photo) {
    if (photo.startsWith('/')) return FileImage(File(photo));
    if (photo.startsWith('http')) return NetworkImage(photo);
    return AssetImage(getPhotoPath(photo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── Gradient AppBar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: _brandRed,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadSavedPlaces,
                tooltip: 'Refresh',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tempat Tersimpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (_savedPlaces.isNotEmpty)
                    Text(
                      '${_savedPlaces.length} lokasi disimpan',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_brandRed, _brandRedLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Icon(
                      Icons.bookmark_rounded,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_savedPlaces.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildPlaceCard(_savedPlaces[index], index),
                  childCount: _savedPlaces.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: _brandRed.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              size: 52,
              color: _brandRed,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada tempat tersimpan',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Simpan Alfamart favoritmu dari\nhalaman detail untuk mudah ditemukan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9E9E9E),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Place Card ─────────────────────────────────────────────────────
  Widget _buildPlaceCard(Map<String, dynamic> place, int index) {
    final rating = (place['rating'] as num?)?.toDouble() ?? 0.0;
    final photo = place['photo']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key('saved-${place['id']}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _removePlace(place, index),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: _brandRed,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_rounded, color: Colors.white, size: 28),
              SizedBox(height: 4),
              Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          shadowColor: Colors.black12,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(place: place),
                ),
              ).then((_) => _loadSavedPlaces());
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Foto
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 68,
                      height: 68,
                      child: photo.isEmpty
                          ? Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.store_rounded,
                                  color: Colors.grey, size: 30),
                            )
                          : Image(
                              image: _getImageProvider(photo),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.store_rounded,
                                    color: Colors.grey, size: 30),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place['name']?.toString() ?? '-',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF212121),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          place['address']?.toString() ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Rating badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.amber.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: Colors.amber, size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF795548),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFBDBDBD),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}