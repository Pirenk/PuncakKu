import 'package:flutter/material.dart';
import '../models/checklist_item.dart';

class ChecklistCard extends StatelessWidget {
  final ChecklistItem item;
  final bool isEditMode;
  final bool canEdit;
  final bool canToggle;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRequestChange;

  const ChecklistCard({
    super.key,
    required this.item,
    this.isEditMode = true,
    this.canEdit = true,
    this.canToggle = true,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
    this.onRequestChange,
  });

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF1B4D3E);

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Custom Checkbox
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item.isChecked ? primaryDark : Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: item.isChecked ? primaryDark : Colors.grey.shade400,
                    width: 1.8,
                  ),
                ),
                child: item.isChecked
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),

            // Item Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nama,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: item.isChecked
                          ? const Color(0xFF182A22)
                          : const Color(0xFF182A22),
                      decoration: item.isChecked ? null : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.catatan.isNotEmpty
                              ? '${item.jumlah} · ${item.catatan}'
                              : item.jumlah,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Penanggung Jawab badge if assigned
                  if (item.penanggungJawab != null && item.penanggungJawab!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF3EE),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 12,
                            color: primaryDark,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'PJ: @${item.penanggungJawab}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Actions (Edit, Delete, or Request Change)
            if (isEditMode && canEdit) ...[
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 20, color: Colors.grey.shade600),
                onPressed: onEdit,
                splashRadius: 18,
                tooltip: 'Ubah perlengkapan',
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey.shade600),
                onPressed: onDelete,
                splashRadius: 18,
                tooltip: 'Hapus perlengkapan',
              ),
            ] else if (onRequestChange != null) ...[
              IconButton(
                icon: Icon(Icons.flag_outlined, size: 19, color: Colors.grey.shade600),
                onPressed: onRequestChange,
                splashRadius: 18,
                tooltip: 'Ajukan permintaan perubahan ke Ketua',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
