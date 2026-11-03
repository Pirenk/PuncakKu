import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final int totalCount;
  final int readyCount;
  final bool hasUnreadyMandatory;

  const ProgressCard({
    super.key,
    required this.totalCount,
    required this.readyCount,
    required this.hasUnreadyMandatory,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage =
        totalCount == 0 ? 0.0 : (readyCount / totalCount).clamp(0.0, 1.0);
    final int percentInt = (percentage * 100).round();

    String subtitleText;
    if (readyCount == totalCount && totalCount > 0) {
      subtitleText = 'Luar biasa! Semua perlengkapan siap berangkat.';
    } else if (hasUnreadyMandatory) {
      subtitleText = 'Sedikit lagi, lengkapi barang wajib dulu.';
    } else {
      subtitleText = 'Barang wajib lengkap, lengkapi perlengkapan opsional.';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF3EE), // Pale forest green tint
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$readyCount dari $totalCount siap',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF182A22),
                ),
              ),
              Text(
                '$percentInt%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4D3E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: const Color(0xFFD3E5DB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1B4D3E)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitleText,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF355E4E),
            ),
          ),
        ],
      ),
    );
  }
}
