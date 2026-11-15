
class SoloChecklistRecommendation {
  // Rekomendasi untuk pendakian berkemah
  static final List<Map<String, dynamic>> berkemah = [
    {
      'nama': 'Tas carrier',
      'jumlah': 1,
      'satuan': 'buah',
      'kategori': 'wajib',
    },
    {
      'nama': 'Tenda',
      'jumlah': 1,
      'satuan': 'unit',
      'kategori': 'wajib',
    },
    {
      'nama': 'Matras',
      'jumlah': 1,
      'satuan': 'buah',
      'kategori': 'wajib',
    },
    {
      'nama': 'Sleeping bag',
      'jumlah': 1,
      'satuan': 'buah',
      'kategori': 'wajib',
    },
    {
      'nama': 'Jaket hangat',
      'jumlah': 1,
      'satuan': 'buah',
      'kategori': 'wajib',
    },
    {
      'nama': 'Jas hujan',
      'jumlah': 1,
      'satuan': 'buah',
      'kategori': 'wajib',
    },
    {
      'nama': 'Headlamp',
      'jumlah': 1,
      'satuan': 'buah',
      'kategori': 'wajib',
    },
    {
      'nama': 'Air minum',
      'jumlah': 2,
      'satuan': 'liter',
      'kategori': 'wajib',
    },
  ];

  // Rekomendasi untuk pendakian tektok
  static final List<Map<String, dynamic>> tektok = [
    {
      'nama': 'Tas daypack',
      'jumlah': 1,
      'satuan': 'buah',
      'kategori': 'wajib',
    },
    {
      'nama': 'Sepatu trekking',
      'jumlah': 1,
      'satuan': 'pasang',
      'kategori': 'wajib',
    },
    {
      'nama': 'Jaket',
      'jumlah': 1,
      'satuan': 'buah',
      'kategori': 'wajib',
    },
    {
      'nama': 'Jas hujan',
      'jumlah': 1,
      'satuan': 'buah',
      'kategori': 'wajib',
    },
    {
      'nama': 'Headlamp',
      'jumlah': 1,
      'satuan': 'buah',
      'kategori': 'wajib',
    },
    {
      'nama': 'Air minum',
      'jumlah': 2,
      'satuan': 'liter',
      'kategori': 'wajib',
    },
    {
      'nama': 'Makanan ringan',
      'jumlah': 1,
      'satuan': 'paket',
      'kategori': 'wajib',
    },
    {
      'nama': 'P3K pribadi',
      'jumlah': 1,
      'satuan': 'paket',
      'kategori': 'wajib',
    },
  ];

  // Mengambil rekomendasi berdasarkan jenis perjalanan
  static List<Map<String, dynamic>> getRecommendations(
    String jenisPerjalanan,
  ) {
    if (jenisPerjalanan.toLowerCase() == 'berkemah') {
      return berkemah;
    }

    return tektok;
  }
}
