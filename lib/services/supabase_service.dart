import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _url = 'https://gasijumnujkbxbqlnfrz.supabase.co';
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdhc2lqdW1udWprYnhicWxuZnJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMDI0OTYsImV4cCI6MjA5NjY3ODQ5Nn0.KlihvDn7TcMwslXiy_xouwhA6DaSAilF-4GmbH0m8_c';

  static Future<void> initialize() async {
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  static SupabaseClient get _client => Supabase.instance.client;

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Login dengan email dan password (user biasa maupun admin)
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Logout
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// User yang sedang login (null jika belum login)
  static User? get currentUser => _client.auth.currentUser;

  // ── Places ────────────────────────────────────────────────────────────────

  /// Ambil semua data tempat Alfamart
  static Future<List<Map<String, dynamic>>> getPlaces() async {
    final response = await _client
        .from('places')
        .select()
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Tambah tempat baru
  static Future<void> addPlace(Map<String, dynamic> place) async {
    await _client.from('places').insert(place);
  }

  /// Update data tempat berdasarkan id
  static Future<void> updatePlace(
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    await _client.from('places').update(data).eq('id', id);
  }

  /// Hapus tempat berdasarkan id
  static Future<void> deletePlace(dynamic id) async {
    await _client.from('places').delete().eq('id', id);
  }

  // ── Reviews ───────────────────────────────────────────────────────────────

  /// Tambah ulasan dan update rating rata-rata
  static Future<void> addReview({
    required dynamic placeId,
    required List currentReviews,
    required String text,
    required double rating,
  }) async {
    final updatedReviews = [
      ...currentReviews,
      {'text': text, 'rating': rating},
    ];

    double total = 0;
    for (final r in updatedReviews) {
      total += (r['rating'] as num).toDouble();
    }
    final avgRating = total / updatedReviews.length;

    await _client.from('places').update({
      'reviews': updatedReviews,
      'rating': double.parse(avgRating.toStringAsFixed(1)),
    }).eq('id', placeId);
  }
}
