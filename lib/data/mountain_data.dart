class MountainInfo {
  final String nama;
  final int ketinggianMdpl;
  final List<String> jalurList;
  final String deskripsi;

  const MountainInfo({
    required this.nama,
    required this.ketinggianMdpl,
    required this.jalurList,
    required this.deskripsi,
  });
}

class MountainData {
  static const List<MountainInfo> daftarGunungJateng = [
    MountainInfo(
      nama: 'Gunung Merbabu',
      ketinggianMdpl: 3145,
      jalurList: ['via Selo', 'via Suwanting', 'via Thekelan', 'via Wekas'],
      deskripsi: 'Gunung populer di Boyolali dan Magelang dengan sabana rumput hijau luas.',
    ),
    MountainInfo(
      nama: 'Gunung Slamet',
      ketinggianMdpl: 3432,
      jalurList: ['via Bambangan', 'via Guci', 'via Dipajaya', 'via Sawangan'],
      deskripsi: 'Gunung tertinggi di Jawa Tengah dengan medan berpasir dan jalur menantang.',
    ),
    MountainInfo(
      nama: 'Gunung Prau',
      ketinggianMdpl: 2565,
      jalurList: ['via Patakbanteng', 'via Dieng', 'via Dwarawati', 'via Kalilembu'],
      deskripsi: 'Dataran tinggi Dieng dengan pemandangan sunrise dan bukit teletubbies.',
    ),
    MountainInfo(
      nama: 'Gunung Sindoro',
      ketinggianMdpl: 3153,
      jalurList: ['via Kledung', 'via Sigedang', 'via Bansari', 'via Alang-Alang Sewu'],
      deskripsi: 'Pemandangan kawah aktif belerang dan bunga edelweiss di lereng kledung.',
    ),
    MountainInfo(
      nama: 'Gunung Sumbing',
      ketinggianMdpl: 3371,
      jalurList: ['via Garung', 'via Bowongso', 'via Butuh (Nepal Van Java)', 'via Sipetung'],
      deskripsi: 'Puncak sejati dan desa wisata Butuh Kaliangkrik yang ikonik.',
    ),
    MountainInfo(
      nama: 'Gunung Lawu',
      ketinggianMdpl: 3265,
      jalurList: ['via Candi Cetho', 'via Cemoro Sewu', 'via Cemoro Kandang'],
      deskripsi: 'Jalur penuh sejarah dan sabana Hargo Dumilah di perbatasan Jateng-Jatim.',
    ),
  ];

  static const List<String> durasiBerkemah = [
    '2 hari · 1 malam',
    '3 hari · 2 malam',
    '4 hari · 3 malam',
  ];

  static const List<String> durasiTektok = [
    '1 hari (Tek-tok / PP)',
  ];
}
