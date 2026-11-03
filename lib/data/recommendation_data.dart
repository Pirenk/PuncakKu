import '../models/checklist_item.dart';
import '../models/trip_plan.dart';

class RecommendationData {
  /// Menghasilkan rekomendasi awal perlengkapan sesuai dengan gunung,
  /// jalur, jenis perjalanan (berkemah / tek-tok), durasi, dan mode (pribadi / kelompok).
  static List<ChecklistItem> generateInitialItems(
    TripPlan plan, {
    required bool isGroup,
    List<String> joinedUsernames = const [],
  }) {
    final List<ChecklistItem> items = [];
    int idCounter = 1;

    String nextId() => 'item_${idCounter++}';

    final isCamping = plan.jenisPerjalanan == JenisPerjalanan.berkemah;
    final leaderUsername = joinedUsernames.isNotEmpty ? joinedUsernames.first : 'ryan';

    String getAssignee(int index) {
      if (!isGroup || joinedUsernames.isEmpty) return '';
      return joinedUsernames[index % joinedUsernames.length];
    }

    if (!isGroup) {
      // MODE PRIBADI (SOLO)
      // Wajib (sesuai mockup: 6 siap, 2 belum siap)
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Air minum',
        jumlah: '2 liter / orang',
        kategori: ItemCategory.wajib,
        catatan: 'sesuaikan kebutuhan',
        isChecked: true,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Sepatu trekking',
        jumlah: '1 pasang',
        kategori: ItemCategory.wajib,
        catatan: 'sol tidak licin',
        isChecked: true,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Jaket hangat',
        jumlah: '1 buah',
        kategori: ItemCategory.wajib,
        catatan: 'lapisan penghangat (fleece/down)',
        isChecked: true,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'P3K pribadi',
        jumlah: '1 set',
        kategori: ItemCategory.wajib,
        catatan: 'termasuk obat pribadi',
        isChecked: true,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Makanan & camilan',
        jumlah: plan.durasi.contains('1 hari') ? '1 hari' : '2 hari',
        kategori: ItemCategory.wajib,
        catatan: 'cadangan secukupnya',
        isChecked: true,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Kantong sampah',
        jumlah: '2 buah',
        kategori: ItemCategory.wajib,
        catatan: 'bawa turun kembali',
        isChecked: true,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Lampu kepala',
        jumlah: '1 buah',
        kategori: ItemCategory.wajib,
        catatan: 'baterai cadangan',
        isChecked: false,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Jas hujan',
        jumlah: '1 set',
        kategori: ItemCategory.wajib,
        catatan: 'mudah dijangkau di ransel',
        isChecked: false,
      ));

      if (isCamping) {
        items.add(ChecklistItem(
          id: nextId(),
          nama: 'Tenda solo / bivak',
          jumlah: '1 set',
          kategori: ItemCategory.wajib,
          catatan: 'waterproof double layer',
          isChecked: true,
        ));
        items.add(ChecklistItem(
          id: nextId(),
          nama: 'Matras & sleeping bag',
          jumlah: '1 set',
          kategori: ItemCategory.wajib,
          catatan: 'comfort rating 10°C',
          isChecked: false,
        ));
      }

      // Opsional
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Tongkat trekking',
        jumlah: '1 pasang',
        kategori: ItemCategory.opsional,
        catatan: 'bantu kestabilan',
        isChecked: false,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Kamera',
        jumlah: '1 buah',
        kategori: ItemCategory.opsional,
        catatan: 'sesuai kebutuhan',
        isChecked: false,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Powerbank',
        jumlah: '1 unit',
        kategori: ItemCategory.opsional,
        catatan: '10.000 mAh & kabel data',
        isChecked: true,
      ));
    } else {
      // MODE KELOMPOK
      int assigneeIdx = 0;

      // Barang Wajib Kelompok (Tenda, kompor, masak, logistik, P3K)
      if (isCamping) {
        final tentCapacity = plan.jumlahAnggota <= 4 ? plan.jumlahAnggota : 4;
        items.add(ChecklistItem(
          id: nextId(),
          nama: 'Tenda dome (kapasitas $tentCapacity)',
          jumlah: plan.jumlahAnggota > 4 ? '2 unit' : '1 unit',
          kategori: ItemCategory.wajib,
          catatan: 'frame utuh, pasak & flysheet lengkap',
          isChecked: true,
          penanggungJawab: getAssignee(assigneeIdx++),
          isKelompok: true,
        ));
        items.add(ChecklistItem(
          id: nextId(),
          nama: 'Kompor portabel & gas kaleng',
          jumlah: '2 set + 3 kaleng',
          kategori: ItemCategory.wajib,
          catatan: 'cek pemantik dan segel gas',
          isChecked: true,
          penanggungJawab: getAssignee(assigneeIdx++),
          isKelompok: true,
        ));
        items.add(ChecklistItem(
          id: nextId(),
          nama: 'Nesting / set alat masak',
          jumlah: '1 set lengkap',
          kategori: ItemCategory.wajib,
          catatan: 'termasuk sendok & centong',
          isChecked: true,
          penanggungJawab: getAssignee(assigneeIdx++),
          isKelompok: true,
        ));
      }

      items.add(ChecklistItem(
        id: nextId(),
        nama: 'P3K kelompok & obat darurat',
        jumlah: '1 kotak',
        kategori: ItemCategory.wajib,
        catatan: 'perban, betadine, paracetamol, oksigen kaleng',
        isChecked: true,
        penanggungJawab: leaderUsername,
        isKelompok: true,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Trashbag / kantong sampah besar',
        jumlah: '4 lembar',
        kategori: ItemCategory.wajib,
        catatan: 'wajib bawa turun semua sampah tim',
        isChecked: true,
        penanggungJawab: getAssignee(assigneeIdx++),
        isKelompok: true,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Air cadangan kelompok',
        jumlah: '${plan.jumlahAnggota * 1.5} liter',
        kategori: ItemCategory.wajib,
        catatan: 'khusus masak bersama di pos/camp',
        isChecked: false,
        penanggungJawab: getAssignee(assigneeIdx++),
        isKelompok: true,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Lampu kepala & baterai cadangan',
        jumlah: '1 per anggota',
        kategori: ItemCategory.wajib,
        catatan: 'pastikan baterai baru',
        isChecked: false,
        penanggungJawab: leaderUsername,
        isKelompok: false,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Jas hujan ponco tim',
        jumlah: '${plan.jumlahAnggota} set',
        kategori: ItemCategory.wajib,
        catatan: 'siapkan di bagian atas carrier',
        isChecked: false,
        penanggungJawab: getAssignee(assigneeIdx++),
        isKelompok: false,
      ));

      // Opsional
      if (isCamping) {
        items.add(ChecklistItem(
          id: nextId(),
          nama: 'Flysheet 3x4 & tali prusik',
          jumlah: '1 lembar',
          kategori: ItemCategory.opsional,
          catatan: 'atap tambahan area masak/kumpul',
          isChecked: true,
          penanggungJawab: getAssignee(assigneeIdx++),
          isKelompok: true,
        ));
        items.add(ChecklistItem(
          id: nextId(),
          nama: 'Lampu tenda / lentera',
          jumlah: '1 buah',
          kategori: ItemCategory.opsional,
          catatan: 'penerangan dalam tenda',
          isChecked: false,
          penanggungJawab: getAssignee(assigneeIdx++),
          isKelompok: true,
        ));
      }

      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Tongkat trekking (pole)',
        jumlah: '2 pasang',
        kategori: ItemCategory.opsional,
        catatan: 'bantu beban lutut saat turunan',
        isChecked: false,
        penanggungJawab: getAssignee(assigneeIdx++),
        isKelompok: false,
      ));
      items.add(ChecklistItem(
        id: nextId(),
        nama: 'Kamera / tripod dokumentasi',
        jumlah: '1 buah',
        kategori: ItemCategory.opsional,
        catatan: 'dokumentasi perjalanan',
        isChecked: false,
        penanggungJawab: getAssignee(assigneeIdx++),
        isKelompok: false,
      ));
    }

    return items;
  }
}
