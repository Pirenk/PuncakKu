import 'package:flutter/material.dart';
import '../../models/checklist_item.dart';
import '../../state/pendaki_state.dart';

class ItemFormScreen extends StatefulWidget {
  final PendakiState state;
  final ChecklistItem? itemToEdit;

  const ItemFormScreen({
    super.key,
    required this.state,
    this.itemToEdit,
  });

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  late TextEditingController _namaController;
  late TextEditingController _jumlahController;
  late TextEditingController _catatanController;
  late ItemCategory _kategori;
  String? _selectedPenanggungJawab;

  final Color _primaryDark = const Color(0xFF1B4D3E);

  @override
  void initState() {
    super.initState();
    final it = widget.itemToEdit;
    _namaController = TextEditingController(text: it?.nama ?? '');
    _jumlahController = TextEditingController(text: it?.jumlah ?? '1 buah');
    _catatanController = TextEditingController(text: it?.catatan ?? '');
    _kategori = it?.kategori ?? ItemCategory.wajib;

    if (widget.state.isGroupMode) {
      _selectedPenanggungJawab = it?.penanggungJawab ?? widget.state.activeUsername;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _saveItem() {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama perlengkapan tidak boleh kosong.')),
      );
      return;
    }

    final jumlah = _jumlahController.text.trim().isEmpty
        ? '1 buah'
        : _jumlahController.text.trim();

    if (widget.itemToEdit != null) {
      final updated = widget.itemToEdit!.copyWith(
        nama: nama,
        jumlah: jumlah,
        kategori: _kategori,
        catatan: _catatanController.text.trim(),
        penanggungJawab: widget.state.isGroupMode ? _selectedPenanggungJawab : null,
      );
      widget.state.updateItem(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan barang berhasil disimpan.')),
      );
    } else {
      final newItem = ChecklistItem(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}',
        nama: nama,
        jumlah: jumlah,
        kategori: _kategori,
        catatan: _catatanController.text.trim(),
        isChecked: false,
        penanggungJawab: widget.state.isGroupMode ? _selectedPenanggungJawab : null,
        isKelompok: widget.state.isGroupMode,
      );
      widget.state.addItem(newItem);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perlengkapan baru berhasil ditambahkan.')),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;
    final plan = widget.state.plan;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF182A22)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Ubah perlengkapan' : 'Tambah perlengkapan',
          style: const TextStyle(
            color: Color(0xFF182A22),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle like mockup: "Merbabu · Lampu kepala"
            Text(
              '${plan.gunung.replaceAll("Gunung ", "")} · ${isEditing ? widget.itemToEdit!.nama : "Barang baru"}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),

            // Headline
            const Text(
              'Detail barang',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF182A22),
              ),
            ),
            const SizedBox(height: 20),

            // Nama barang
            _buildFieldLabel('Nama barang'),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _namaController,
              hint: 'Contoh: Lampu kepala',
            ),
            const SizedBox(height: 20),

            // Jumlah
            _buildFieldLabel('Jumlah'),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _jumlahController,
              hint: 'Contoh: 1 buah atau 2 liter',
            ),
            const SizedBox(height: 20),

            // Kategori
            _buildFieldLabel('Kategori'),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildChoiceChip(
                  label: 'Wajib',
                  isSelected: _kategori == ItemCategory.wajib,
                  onSelected: () {
                    setState(() {
                      _kategori = ItemCategory.wajib;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildChoiceChip(
                  label: 'Opsional',
                  isSelected: _kategori == ItemCategory.opsional,
                  onSelected: () {
                    setState(() {
                      _kategori = ItemCategory.opsional;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Penanggung Jawab (if group mode)
            if (widget.state.isGroupMode) ...[
              _buildFieldLabel('Penanggung Jawab (PJ)'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPenanggungJawab,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    items: widget.state.acceptedUsernames.map((u) {
                      return DropdownMenuItem<String>(
                        value: u,
                        child: Text(
                          '@$u ${u == "ryan" ? "(Ketua)" : "(Anggota)"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF182A22),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedPenanggungJawab = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Catatan (opsional)
            _buildFieldLabel('Catatan (opsional)'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _catatanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Bawa baterai cadangan',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13.5),
                  contentPadding: EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Button Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                ),
                onPressed: _saveItem,
                child: Text(
                  isEditing ? 'Simpan perubahan barang' : 'Tambah perlengkapan',
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Button Batal
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryDark,
                  side: BorderSide(color: Colors.grey.shade300),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal · kembali ke checklist',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.bold,
        color: Color(0xFF182A22),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? _primaryDark : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? _primaryDark : Colors.grey.shade300,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF182A22),
            ),
          ),
        ),
      ),
    );
  }
}
