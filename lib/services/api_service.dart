import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.2/pendaki_api';


// Membuat perjalanan atau kelompok baru
static Future<int> createTrip({
  required int ownerId,
  required String gunung,
  required String jalur,
  required String jenisPerjalanan, 
  required String durasi,
  required int jumlahAnggota,
  String mode = 'kelompok',
}) async {
  final url = Uri.parse('$baseUrl/trips/create.php');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'owner_id': ownerId,
      'gunung': gunung,
      'jalur': jalur,
      'jenis_perjalanan': jenisPerjalanan,
      'durasi': durasi,
      'jumlah_anggota': jumlahAnggota,
      'mode': mode,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['status'] == 'success') {
    return int.parse(data['trip_id'].toString());
  }

  throw Exception(data['message'] ?? 'Gagal membuat perjalanan');
}


  // Mengambil daftar checklist
  static Future<List<dynamic>> getChecklist(int tripId) async {
    final url = Uri.parse('$baseUrl/checklist/list.php?trip_id=$tripId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        return data['data'];
      }

      throw Exception(data['message']);
    }

    throw Exception('Gagal mengambil data checklist');
  }


  // Mengambil daftar anggota kelompok
  static Future<List<dynamic>> getGroupMembers(int tripId) async {
    final url = Uri.parse(
      '$baseUrl/group/members.php?trip_id=$tripId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return data['data'];
      }

      throw Exception(data['message'] ?? 'Gagal mengambil anggota kelompok');
    }

    throw Exception('Gagal menghubungi API anggota kelompok');
  }
  
  // Menambahkan perlengkapan baru
  static Future<int> addChecklist({
    required int tripId,
    required int createdBy,
    required String nama,
    required int jumlah,
    required String satuan,
    required String kategori,
    String catatan = '',
    bool isChecked = false,
    bool isKelompok = false,
    int? penanggungJawabId,
  }) async {
    final url = Uri.parse('$baseUrl/checklist/add.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'trip_id': tripId,
        'created_by': createdBy,
        'nama': nama,
        'jumlah': jumlah,
        'satuan': satuan,
        'kategori': kategori,
        'catatan': catatan,
        'is_checked': isChecked ? 1 : 0,
        'is_kelompok': isKelompok ? 1 : 0,
        'penanggung_jawab_id': penanggungJawabId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return int.parse(data['id'].toString());
    }

    throw Exception(data['message'] ?? 'Gagal menambahkan perlengkapan');
  }


  static Future<void> deleteChecklist(int id) async {
    final url = Uri.parse('$baseUrl/checklist/delete.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return;
    }

    throw Exception(data['message'] ?? 'Gagal menghapus perlengkapan');
  }

 static Future<void> updateChecklist({
  required int id,
  required String nama,
  required int jumlah,
  required String satuan,
  required String kategori,
}) async {
  final url = Uri.parse('$baseUrl/checklist/update.php');

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'id': id,
      'nama': nama,
      'jumlah': jumlah,
      'satuan': satuan,
      'kategori': kategori,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['status'] == 'success') {
    return;
  }

  throw Exception(data['message'] ?? 'Gagal memperbarui perlengkapan');
}

  static Future<void> updateChecklistAssignee({
    required int id,
    required int penanggungJawabId,
    required String nama,
    required int jumlah,
    required String satuan,
    required String kategori,
  }) async {
    final url = Uri.parse('$baseUrl/checklist/assign.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'penanggung_jawab_id': penanggungJawabId,
        'is_kelompok': 1,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return;
    }

    throw Exception(data['message'] ?? 'Gagal mengatur penanggung jawab');
  }

  static Future<void> updateChecklistStatus({
    required int id,
    required bool isChecked,
  }) async {
    final url = Uri.parse('$baseUrl/checklist/status.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'is_checked': isChecked ? 1 : 0}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return;
    }

    throw Exception(data['message'] ?? 'Gagal memperbarui status checklist');
  }


  // Mengajukan permintaan perubahan checklist
  static Future<int> submitChangeRequest({
    required int tripId,
    required int pengajuId,
    required String jenis,
    int? targetItemId,
    String? namaPerlengkapan,
    int? jumlahBaru,
    String? catatanBaru,
    String? alasan,
  }) async {
    final url = Uri.parse('$baseUrl/checklist/request_add.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'trip_id': tripId,
        'pengaju_id': pengajuId,
        'jenis': jenis,
        'target_item_id': targetItemId,
        'nama_perlengkapan': namaPerlengkapan,
        'jumlah_baru': jumlahBaru,
        'catatan_baru': catatanBaru,
        'alasan': alasan,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return int.parse(data['id'].toString());
    }

    throw Exception(data['message'] ?? 'Gagal mengajukan perubahan');
  }

  // Mengambil daftar permintaan perubahan
  static Future<List<dynamic>> getChangeRequests(int tripId) async {
    final url = Uri.parse(
      '$baseUrl/checklist/request_list.php?trip_id=$tripId',
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return data['data'];
    }

    throw Exception(data['message'] ?? 'Gagal mengambil permintaan');
  }

  // Menyetujui permintaan perubahan
  static Future<void> approveChangeRequest({
    required int requestId,
    required int diprosesOleh,
  }) async {
    final url = Uri.parse('$baseUrl/checklist/request_approve.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'request_id': requestId,
        'diproses_oleh': diprosesOleh,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return;
    }

    throw Exception(data['message'] ?? 'Gagal menyetujui permintaan');
  }

  // Menolak permintaan perubahan
  static Future<void> rejectChangeRequest({
    required int requestId,
    required int diprosesOleh,
  }) async {
    final url = Uri.parse('$baseUrl/checklist/request_reject.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'request_id': requestId,
        'diproses_oleh': diprosesOleh,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return;
    }

    throw Exception(data['message'] ?? 'Gagal menolak permintaan');
  }

  // Mengambil daftar gunung dari database (dengan pencarian, filter kesulitan, lokasi)
  static Future<List<dynamic>> getDaftarGunung({
    String search = '',
    String kesulitan = '',
    String lokasi = '',
  }) async {
    final queryParams = <String, String>{};
    if (search.isNotEmpty) queryParams['search'] = search;
    if (kesulitan.isNotEmpty && kesulitan != 'Semua') queryParams['kesulitan'] = kesulitan;
    if (lokasi.isNotEmpty) queryParams['lokasi'] = lokasi;

    final uri = Uri.parse('$baseUrl/gunung/list.php').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['data'] ?? [];
      }
    }
    return [];
  }

  // Mengambil detail gunung beserta jalur pendakian dari database
  static Future<Map<String, dynamic>?> getDetailGunung(int idGunung) async {
    final uri = Uri.parse('$baseUrl/gunung/detail.php?id=$idGunung');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['data'];
      }
    }
    return null;
  }
}
