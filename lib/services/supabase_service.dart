import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _url = 'https://gasijumnujkbxbqlnfrz.supabase.co';
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdhc2lqdW1udWprYnhicWxuZnJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMDI0OTYsImV4cCI6MjA5NjY3ODQ5Nn0.KlihvDn7TcMwslXiy_xouwhA6DaSAilF-4GmbH0m8_c';

  static Future<void> initialize() async {
    await Supabase.initialize(url: _url, publishableKey: _anonKey);
  }

  static SupabaseClient get _client => Supabase.instance.client;

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Login dengan email dan password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Register akun baru
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  /// Logout
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// User yang sedang login (null jika belum login)
  static User? get currentUser => _client.auth.currentUser;

  // ── Profiles & Roles ──────────────────────────────────────────────────────

  /// Ambil profil user yang sedang login
  static Future<Map<String, dynamic>?> getProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    final response =
        await _client.from('profiles').select().eq('id', uid).maybeSingle();
    return response;
  }

  /// Cek apakah user yang login adalah admin
  static Future<bool> isAdmin() async {
    final profile = await getProfile();
    return profile?['role'] == 'admin';
  }

  // ── Places ────────────────────────────────────────────────────────────────

  /// Ambil semua data tempat Alfamart
  static Future<List<Map<String, dynamic>>> getPlaces() async {
    final response = await _client
        .from('places')
        .select()
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Tambah tempat baru (admin only)
  static Future<void> addPlace(Map<String, dynamic> place) async {
    await _client.from('places').insert(place);
  }

  /// Update data tempat berdasarkan id (admin only)
  static Future<void> updatePlace(dynamic id, Map<String, dynamic> data) async {
    await _client.from('places').update(data).eq('id', id);
  }

  /// Hapus tempat berdasarkan id (admin only)
  static Future<void> deletePlace(dynamic id) async {
    await _client.from('places').delete().eq('id', id);
  }

  // ── Saved Places (per user) ───────────────────────────────────────────────

  /// Ambil semua saved places milik user yang login
  static Future<List<Map<String, dynamic>>> getSavedPlaces() async {
    final uid = currentUser?.id;
    if (uid == null) return [];
    final response = await _client
        .from('saved_places')
        .select('place_id, places(*)')
        .eq('user_id', uid);
    return List<Map<String, dynamic>>.from(
      response.map((e) => e['places'] as Map<String, dynamic>),
    );
  }

  /// Simpan tempat untuk user yang login
  static Future<void> savePlace(dynamic placeId) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    await _client.from('saved_places').insert({
      'user_id': uid,
      'place_id': placeId,
    });
  }

  /// Hapus tempat dari saved milik user yang login
  static Future<void> unsavePlace(dynamic placeId) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    await _client
        .from('saved_places')
        .delete()
        .eq('user_id', uid)
        .eq('place_id', placeId);
  }

  /// Cek apakah tempat sudah disimpan oleh user yang login
  static Future<bool> isSaved(dynamic placeId) async {
    final uid = currentUser?.id;
    if (uid == null) return false;
    final response =
        await _client
            .from('saved_places')
            .select('id')
            .eq('user_id', uid)
            .eq('place_id', placeId)
            .maybeSingle();
    return response != null;
  }

  // ── Reviews (per user, per tempat) ───────────────────────────────────────

  /// Ambil semua review untuk satu tempat
  static Future<List<Map<String, dynamic>>> getReviews(dynamic placeId) async {
    final response = await _client
        .from('reviews')
        .select('*, profiles(email)')
        .eq('place_id', placeId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Cek apakah user sudah pernah review tempat ini
  static Future<bool> hasReviewed(dynamic placeId) async {
    final uid = currentUser?.id;
    if (uid == null) return false;
    final response =
        await _client
            .from('reviews')
            .select('id')
            .eq('user_id', uid)
            .eq('place_id', placeId)
            .maybeSingle();
    return response != null;
  }

  /// Tambah review baru dan update rata-rata rating di tabel places
  static Future<void> addReview({
    required dynamic placeId,
    required String text,
    required double rating,
  }) async {
    final uid = currentUser?.id;
    if (uid == null) throw Exception('Harus login untuk memberikan ulasan');

    // Insert review
    await _client.from('reviews').insert({
      'user_id': uid,
      'place_id': placeId,
      'text': text,
      'rating': rating,
    });

    // Hitung ulang rata-rata rating dari tabel reviews
    final reviews = await _client
        .from('reviews')
        .select('rating')
        .eq('place_id', placeId);

    final total = (reviews as List).fold<double>(
      0,
      (sum, r) => sum + (r['rating'] as num).toDouble(),
    );
    final avg = total / reviews.length;

    await _client
        .from('places')
        .update({'rating': double.parse(avg.toStringAsFixed(1))})
        .eq('id', placeId);
  }

  /// Hapus review milik sendiri
  static Future<void> deleteReview(dynamic reviewId) async {
    await _client.from('reviews').delete().eq('id', reviewId);
  }
}
