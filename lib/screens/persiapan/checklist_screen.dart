import 'package:flutter/material.dart';
import '../../models/checklist_item.dart';
import '../../state/pendaki_state.dart';
import '../../widgets/checklist_card.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/role_switcher_bar.dart';
import '../../widgets/warning_alert_card.dart';
import 'item_form_screen.dart';

class ChecklistScreen extends StatefulWidget {
  final PendakiState state;

  const ChecklistScreen({super.key, required this.state});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  bool _isEditMode = true; // Can toggle between edit mode (Page 2) and view mode (Page 3)
  final Color _primaryDark = const Color(0xFF1B4D3E);

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final currentFilter = widget.state.checklistFilter;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Filter Perlengkapan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF182A22),
                  ),
                ),
                const SizedBox(height: 12),
                _buildFilterOption('semua', 'Semua Perlengkapan', currentFilter, ctx),
                _buildFilterOption('belum_siap', 'Hanya Belum Siap', currentFilter, ctx),
                _buildFilterOption('wajib', 'Hanya Barang Wajib', currentFilter, ctx),
                if (widget.state.isGroupMode)
                  _buildFilterOption(
                    'tugas_saya',
                    'Tanggung Jawab Saya (@${widget.state.activeUsername})',
                    currentFilter,
                    ctx,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    String filterKey,
    String label,
    String currentFilter,
    BuildContext ctx,
  ) {
    final isSelected = currentFilter == filterKey;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? _primaryDark : const Color(0xFF182A22),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: _primaryDark)
          : null,
      onTap: () {
        widget.state.setChecklistFilter(filterKey);
        Navigator.pop(ctx);
      },
    );
  }

  List<ChecklistItem> _getFilteredItems(List<ChecklistItem> items) {
    final filter = widget.state.checklistFilter;
    switch (filter) {
      case 'belum_siap':
        return items.where((it) => !it.isChecked).toList();
      case 'wajib':
        return items.where((it) => it.isWajib).toList();
      case 'tugas_saya':
        return items
            .where((it) =>
                it.penanggungJawab?.toLowerCase() ==
                widget.state.activeUsername.toLowerCase())
            .toList();
      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.state.plan;
    final group = widget.state.group;
    final isGroup = widget.state.isGroupMode;
    final isKetua = widget.state.isCurrentKetua;

    final allItems = widget.state.items;
    final filteredItems = _getFilteredItems(allItems);

    final wajibItems = filteredItems.where((it) => it.isWajib).toList();
    final opsionalItems = filteredItems.where((it) => it.isOpsional).toList();

    final allWajib = allItems.where((it) => it.isWajib).toList();
    final allOpsional = allItems.where((it) => it.isOpsional).toList();

    final totalReady = allItems.where((it) => it.isChecked).length;
    final unreadyMandatory = allWajib.where((it) => !it.isChecked).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF182A22)),
          onPressed: () {
            widget.state.backFromChecklist();
          },
        ),
        title: const Text(
          'Perlengkapanmu',
          style: TextStyle(
            color: Color(0xFF182A22),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF182A22)),
            onPressed: _showFilterSheet,
            tooltip: 'Filter checklist',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Mountain name and "Ubah rencana"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${plan.gunung.replaceAll("Gunung ", "")} ${plan.jalur}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF182A22),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    // Navigate back to plan editor
                    widget.state.navigateToSubScreen(PersiapanSubScreen.rencana);
                  },
                  child: Text(
                    'Ubah rencana',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),

            // Subtitle info
            Text(
              '${plan.jenisString} · ${plan.durasi} · ${plan.jumlahAnggota} orang · Rekomendasi awal',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 14),

            // Role Switcher Bar (in Group Mode)
            if (isGroup) RoleSwitcherBar(state: widget.state),

            // Warning Notice if some group members haven't accepted yet
            if (isGroup && !group.isAllAccepted) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Perhatian: Masih ada anggota yang belum menerima undangan (${group.joinedCount}/${group.targetCount} bergabung).',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Active Filter Chip if not 'semua'
            if (widget.state.checklistFilter != 'semua') ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF3EE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Filter aktif: ${widget.state.checklistFilter.replaceAll("_", " ")}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _primaryDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => widget.state.setChecklistFilter('semua'),
                      child: const Icon(Icons.close, size: 16, color: Color(0xFF1B4D3E)),
                    ),
                  ],
                ),
              ),
            ],

            // Progress Card
            ProgressCard(
              totalCount: allItems.length,
              readyCount: totalReady,
              hasUnreadyMandatory: unreadyMandatory.isNotEmpty,
            ),

            // Warning Alert Card (when mandatory items are unready)
            WarningAlertCard(
              unreadyCount: unreadyMandatory.length,
              unreadyNames: unreadyMandatory.map((it) => it.nama).toList(),
            ),

            // Section: Wajib dibawa
            if (wajibItems.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Wajib dibawa',
                countText:
                    '${allWajib.where((it) => it.isChecked).length} / ${allWajib.length} siap',
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: wajibItems.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, idx) {
                    final item = wajibItems[idx];
                    return ChecklistCard(
                      item: item,
                      isEditMode: _isEditMode,
                      canEdit: isKetua || !isGroup,
                      canToggle: widget.state.canToggleItem(item),
                      onToggle: () {
                        final errMsg = widget.state.toggleItemCheck(item.id);
                        if (errMsg != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errMsg),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemFormScreen(
                              state: widget.state,
                              itemToEdit: item,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        widget.state.deleteItem(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.nama} telah dihapus.'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      onRequestChange: !isKetua && isGroup
                          ? () {
                              widget.state.navigateToSubScreen(
                                  PersiapanSubScreen.permintaan);
                            }
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Section: Opsional
            if (opsionalItems.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Opsional',
                countText:
                    '${allOpsional.where((it) => it.isChecked).length} / ${allOpsional.length} siap',
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: opsionalItems.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, idx) {
                    final item = opsionalItems[idx];
                    return ChecklistCard(
                      item: item,
                      isEditMode: _isEditMode,
                      canEdit: isKetua || !isGroup,
                      canToggle: widget.state.canToggleItem(item),
                      onToggle: () {
                        final errMsg = widget.state.toggleItemCheck(item.id);
                        if (errMsg != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errMsg),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemFormScreen(
                              state: widget.state,
                              itemToEdit: item,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        widget.state.deleteItem(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.nama} telah dihapus.'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      onRequestChange: !isKetua && isGroup
                          ? () {
                              widget.state.navigateToSubScreen(
                                  PersiapanSubScreen.permintaan);
                            }
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Bottom Buttons
            if (_isEditMode) ...[
              // Button + Tambah perlengkapan (if Ketua or solo)
              if (isKetua || !isGroup) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryDark,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemFormScreen(state: widget.state),
                        ),
                      );
                    },
                    child: const Text(
                      '+ Tambah perlengkapan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                // Anggota request addition button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryDark,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      widget.state.navigateToSubScreen(PersiapanSubScreen.permintaan);
                    },
                    icon: const Icon(Icons.add_comment_outlined, size: 18),
                    label: const Text(
                      '+ Ajukan Tambah Perlengkapan ke Ketua',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Button Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditMode = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Daftar perlengkapan disimpan.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Page 3 Mockup: Single Edit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditMode = true;
                    });
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Footer note like mockup
            Center(
              child: Text(
                'Perlengkapan kelompok seperti tenda dan alat masak perlu dibagi serta dikonfirmasi bersama.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String countText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF182A22),
          ),
        ),
        Text(
          countText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
