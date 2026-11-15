import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // IP Laptop Anda di jaringan Wi-Fi (pastikan HP dan Laptop di Wi-Fi yang sama)
  static const String baseUrl = "http://192.168.137.110/pendaki_api";

  // Header request standar
  static Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  /// Login Biasa (Email & Password)
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/auth/login.php");
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({
              "email": email,
              "password": password,
              "is_google": false,
            }),
          )
          .timeout(const Duration(seconds: 7));

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("API Error login: $e");
      return {
        "status": "error",
        "message": "Gagal terhubung ke server Laragon ($e)",
      };
    }
  }

  /// Login / Sinkronisasi Akun Google ke MySQL
  static Future<Map<String, dynamic>> syncGoogleUser({
    required String email,
    required String nama,
    required String fotoProfil,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/auth/login.php");
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({
              "email": email,
              "nama": nama,
              "foto_profil": fotoProfil,
              "is_google": true,
            }),
          )
          .timeout(const Duration(seconds: 7));

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("API Error syncGoogleUser: $e");
      return {"status": "error", "message": "Gagal sinkron ke MySQL: $e"};
    }
  }

  /// Ambil Daftar Gunung Rekomendasi dari Database MySQL
  static Future<List<Map<String, dynamic>>> getGunung({String? search}) async {
    try {
      String path = "$baseUrl/gunung/list.php";
      if (search != null && search.isNotEmpty) {
        path += "?search=${Uri.encodeComponent(search)}";
      }

      final url = Uri.parse(path);
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['status'] == 'success' && res['data'] is List) {
          return List<Map<String, dynamic>>.from(res['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint("API Error getGunung: $e");
      return [];
    }
  }

  /// Ambil Profil Lengkap Pengguna dari Database MySQL
  static Future<Map<String, dynamic>?> getProfile({
    int? userId,
    String? email,
  }) async {
    try {
      String query = "";
      if (userId != null) {
        query = "user_id=$userId";
      } else if (email != null) {
        query = "email=${Uri.encodeComponent(email)}";
      }

      final url = Uri.parse("$baseUrl/user/profile.php?$query");
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['status'] == 'success') {
          return res['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint("API Error getProfile: $e");
      return null;
    }
  }

  /// Perbarui Profil Pengguna ke Database MySQL
  static Future<bool> updateProfile({
    required int userId,
    required String nama,
    String? fotoProfil,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/user/update_profile.php");
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({
              "user_id": userId,
              "nama": nama,
              "foto_profil": fotoProfil ?? '',
            }),
          )
          .timeout(const Duration(seconds: 7));

      final res = jsonDecode(response.body);
      return res['status'] == 'success';
    } catch (e) {
      debugPrint("API Error updateProfile: $e");
      return false;
    }
  }

  // ============================================================
  // POSTINGAN / KOMUNITAS (Tabel: postingan, like_postingan, komentar)
  // ============================================================

  /// Ambil Semua Postingan Komunitas dari Database MySQL
  static Future<List<Map<String, dynamic>>> getPostingan({int? userId}) async {
    try {
      String path = "$baseUrl/postingan/list.php";
      if (userId != null && userId > 0) {
        path += "?user_id=$userId";
      }

      final url = Uri.parse(path);
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['status'] == 'success' && res['data'] is List) {
          return List<Map<String, dynamic>>.from(res['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint("API Error getPostingan: $e");
      return [];
    }
  }

  /// Buat Postingan Baru ke Tabel postingan
  static Future<Map<String, dynamic>> createPostingan({
    required int userId,
    required String caption,
    String? foto,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/postingan/create.php");
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({
              "id_user": userId,
              "caption": caption,
              "foto": foto ?? "",
            }),
          )
          .timeout(const Duration(seconds: 8));

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("API Error createPostingan: $e");
      return {"status": "error", "message": "Gagal membuat postingan: $e"};
    }
  }

  /// Toggle Like / Unlike Postingan di Tabel like_postingan
  static Future<Map<String, dynamic>> toggleLikePostingan({
    required int idPostingan,
    required int userId,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/postingan/like.php");
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({"id_postingan": idPostingan, "id_user": userId}),
          )
          .timeout(const Duration(seconds: 6));

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("API Error toggleLikePostingan: $e");
      return {"status": "error", "message": "Gagal menyukai: $e"};
    }
  }

  /// Ambil Komentar Suatu Postingan dari Tabel komentar
  static Future<List<Map<String, dynamic>>> getKomentar(int idPostingan) async {
    try {
      final url = Uri.parse(
        "$baseUrl/postingan/komentar.php?id_postingan=$idPostingan",
      );
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['status'] == 'success' && res['data'] is List) {
          return List<Map<String, dynamic>>.from(res['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint("API Error getKomentar: $e");
      return [];
    }
  }

  /// Tambah Komentar Baru ke Tabel komentar
  static Future<Map<String, dynamic>> addKomentar({
    required int idPostingan,
    required int userId,
    required String isiKomentar,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/postingan/komentar.php");
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({
              "id_postingan": idPostingan,
              "id_user": userId,
              "isi_komentar": isiKomentar,
            }),
          )
          .timeout(const Duration(seconds: 6));

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("API Error addKomentar: $e");
      return {"status": "error", "message": "Gagal mengirim komentar: $e"};
    }
  }

  /// Perbarui Caption Postingan di Tabel postingan
  static Future<bool> updatePostingan({
    required int idPostingan,
    required String caption,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/postingan/update.php");
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({"id_postingan": idPostingan, "caption": caption}),
          )
          .timeout(const Duration(seconds: 6));

      final res = jsonDecode(response.body);
      return res['status'] == 'success';
    } catch (e) {
      debugPrint("API Error updatePostingan: $e");
      return false;
    }
  }

  /// Hapus Postingan dari Tabel postingan
  static Future<bool> deletePostingan(int idPostingan) async {
    try {
      final url = Uri.parse("$baseUrl/postingan/delete.php");
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({"id_postingan": idPostingan}),
          )
          .timeout(const Duration(seconds: 6));

      final res = jsonDecode(response.body);
      return res['status'] == 'success';
    } catch (e) {
      debugPrint("API Error deletePostingan: $e");
      return false;
    }
  }
}
