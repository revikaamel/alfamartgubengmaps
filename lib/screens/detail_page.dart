import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../data/places.dart';
import 'route_page.dart';

class DetailPage extends StatefulWidget {
  final Map place;

  const DetailPage({super.key, required this.place});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  static const Color _brandRed = Color(0xFFD32F2F);

  List reviews = [];
  late double averageRating;
  double userRating = 0.0;

  final TextEditingController reviewController = TextEditingController();

  double toDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0.0;

  @override
  void initState() {
    super.initState();
    loadReviews();
    calculateAverageRating();
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  void loadReviews() {
    reviews = List.from(widget.place['reviews'] ?? []);
  }

  void calculateAverageRating() {
    if (reviews.isEmpty) {
      averageRating = toDouble(widget.place['rating']);
      return;
    }
    double total = 0.0;
    for (var review in reviews) {
      total += toDouble(review['rating']);
    }
    averageRating = total / reviews.length;
  }

  bool isSaved() => savedPlaces.any(
        (item) => item['name'] == widget.place['name'],
      );

  void toggleSave() {
    setState(() {
      if (isSaved()) {
        savedPlaces.removeWhere(
          (item) => item['name'] == widget.place['name'],
        );
      } else {
        savedPlaces.add(widget.place);
      }
    });
  }

  void addReview() {
    if (reviewController.text.trim().isEmpty || userRating == 0.0) return;

    setState(() {
      reviews.add({
        'text': reviewController.text.trim(),
        'rating': userRating,
      });
      widget.place['reviews'] = reviews;
      calculateAverageRating();
    });

    reviewController.clear();
    userRating = 0.0;
    Navigator.pop(context);
  }

  String getPhotoPath(String photo) {
    if (photo.contains('assets/images/')) return photo;
    return 'assets/images/$photo';
  }

  ImageProvider _getImageProvider(String photo) {
    if (photo.startsWith('/')) return FileImage(File(photo));
    return AssetImage(getPhotoPath(photo));
  }

  // ── Bottom sheet tambah ulasan ───────────────────────────────────────────
  void _showReviewSheet() {
    userRating = 0.0;
    reviewController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(builderContext).viewInsets.bottom + 24.0,
                top: 8.0,
                left: 24.0,
                right: 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40.0,
                      height: 4.0,
                      margin: const EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 44.0,
                        height: 44.0,
                        decoration: BoxDecoration(
                          color: _brandRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Icon(
                          Icons.rate_review_rounded,
                          color: _brandRed,
                          size: 24.0,
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tulis Ulasan',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF212121),
                            ),
                          ),
                          Text(
                            widget.place['name']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Color(0xFF9E9E9E),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28.0),

                  // Label rating
                  const Text(
                    'Beri Penilaian',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Bintang interaktif
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final double starValue = (i + 1).toDouble();
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() => userRating = starValue);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 4.0),
                          child: AnimatedScale(
                            scale: userRating >= starValue ? 1.25 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack,
                            child: Icon(
                              userRating >= starValue
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: userRating >= starValue
                                  ? Colors.amber
                                  : Colors.grey.shade300,
                              size: 40.0,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  // Label nilai rating
                  const SizedBox(height: 8.0),
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        userRating == 0.0
                            ? 'Ketuk bintang untuk memberi nilai'
                            : _ratingLabel(userRating),
                        key: ValueKey<double>(userRating),
                        style: TextStyle(
                          fontSize: 13.0,
                          color: userRating == 0.0
                              ? Colors.grey.shade400
                              : Colors.amber.shade700,
                          fontWeight: userRating == 0.0
                              ? FontWeight.w400
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // Field ulasan
                  const Text(
                    'Komentar',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText:
                          'Bagikan pengalamanmu di Alfamart ini...',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 14.0),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.all(16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(
                            color: _brandRed, width: 1.5),
                      ),
                      counterStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Tombol kirim
                  SizedBox(
                    width: double.infinity,
                    height: 52.0,
                    child: ElevatedButton(
                      onPressed: () {
                        if (reviewController.text.trim().isEmpty ||
                            userRating == 0.0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Lengkapi bintang dan komentar terlebih dahulu'),
                              backgroundColor: Colors.grey.shade800,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                            ),
                          );
                          return;
                        }
                        addReview();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandRed,
                        foregroundColor: Colors.white,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18.0),
                          SizedBox(width: 8.0),
                          Text(
                            'Kirim Ulasan',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _ratingLabel(double rating) {
    if (rating >= 5) return '⭐ Luar Biasa!';
    if (rating >= 4) return '😊 Sangat Baik';
    if (rating >= 3) return '👍 Cukup Baik';
    if (rating >= 2) return '😐 Kurang Memuaskan';
    return '👎 Mengecewakan';
  }

  // ── Build utama ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar dengan foto ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260.0,
            pinned: true,
            backgroundColor: _brandRed,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    isSaved()
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    key: ValueKey<bool>(isSaved()),
                    color: Colors.white,
                  ),
                ),
                onPressed: toggleSave,
                tooltip: isSaved() ? 'Hapus dari tersimpan' : 'Simpan',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: _getImageProvider(
                      widget.place['photo']?.toString() ?? '',
                    ),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.store_rounded,
                          size: 60.0, color: Colors.grey),
                    ),
                  ),
                  // Gradient overlay bawah
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Konten ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Card info utama ─────────────────────────────────────
                Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12.0,
                          offset: Offset(0.0, 4.0)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.place['name']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: _brandRed, size: 16.0),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              widget.place['address']?.toString() ?? '-',
                              style: const TextStyle(
                                fontSize: 13.0,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      // Rating summary
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(14.0),
                          border:
                              Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 28.0),
                            const SizedBox(width: 8.0),
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF795548),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              '/ 5.0',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${reviews.length} ulasan',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Tombol aksi ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.route_rounded,
                          label: 'Lihat Rute',
                          color: _brandRed,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RoutePage(place: widget.place),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.rate_review_rounded,
                          label: 'Tulis Ulasan',
                          color: const Color(0xFF1565C0),
                          onTap: _showReviewSheet,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24.0),

                // ── Daftar ulasan ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Text(
                        'Ulasan',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: _brandRed,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          '${reviews.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),

                if (reviews.isEmpty)
                  _buildEmptyReview()
                else
                  ...reviews.map((review) => _ReviewCard(review: review)),

                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.reviews_rounded, size: 44.0, color: Colors.grey.shade300),
          const SizedBox(height: 12.0),
          Text(
            'Belum ada ulasan',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Jadilah yang pertama memberi ulasan!',
            style: TextStyle(fontSize: 12.0, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ── Action Button ──────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10.0,
              offset: const Offset(0.0, 4.0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18.0),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Review Card ───────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final dynamic review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final double rating =
        double.tryParse(review['rating']?.toString() ?? '0') ?? 0.0;
    final int ratingInt = rating.round().clamp(0, 5);

    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0.0, 2.0)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar inisial
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFFD32F2F),
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengguna Anonim',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.0,
                      color: Color(0xFF212121),
                    ),
                  ),
                  // Bintang
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < ratingInt
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 14.0,
                      );
                    }),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.0,
                    color: Color(0xFF795548),
                  ),
                ),
              ),
            ],
          ),
          if (review['text']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: 10.0),
            Text(
              review['text'].toString(),
              style: const TextStyle(
                fontSize: 13.0,
                color: Color(0xFF616161),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
