import 'package:flutter/material.dart';

class WarningAlertCard extends StatelessWidget {
  final int unreadyCount;
  final List<String> unreadyNames;

  const WarningAlertCard({
    super.key,
    required this.unreadyCount,
    required this.unreadyNames,
  });

  @override
  Widget build(BuildContext context) {
    if (unreadyCount == 0) return const SizedBox.shrink();

    final namesText = unreadyNames.take(3).join(', ') +
        (unreadyNames.length > 3 ? ' dan lainnya' : '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7E7), // Soft amber background
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFD97706),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unreadyCount barang wajib belum siap',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$namesText. Jangan berangkat sebelum perlengkapan wajib lengkap.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFFB45309),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
