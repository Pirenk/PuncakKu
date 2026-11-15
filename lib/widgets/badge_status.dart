import 'package:flutter/material.dart';
import '../models/change_request.dart';
import '../models/group_member.dart';

class StatusBadge extends StatelessWidget {
  final MemberStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;
    IconData icon;

    switch (status) {
      case MemberStatus.menunggu:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        label = 'Menunggu';
        icon = Icons.hourglass_top_rounded;
        break;
      case MemberStatus.diterima:
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF166534);
        label = 'Diterima';
        icon = Icons.check_circle_outline_rounded;
        break;
      case MemberStatus.ditolak:
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        label = 'Ditolak';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}

class RoleBadge extends StatelessWidget {
  final MemberRole role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isKetua = role == MemberRole.ketua;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isKetua ? const Color(0xFFE0F2FE) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isKetua ? const Color(0xFFBAE6FD) : Colors.grey.shade300,
          width: 0.8,
        ),
      ),
      child: Text(
        isKetua ? 'Ketua' : 'Anggota',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: isKetua ? const Color(0xFF0369A1) : Colors.grey.shade700,
        ),
      ),
    );
  }
}

class RequestTypeBadge extends StatelessWidget {
  final RequestType type;

  const RequestTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (type) {
      case RequestType.tambah:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        label = '+ Tambah';
        break;
      case RequestType.ubah:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        label = '✎ Ubah';
        break;
      case RequestType.hapus:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = '✕ Hapus';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}

class RequestStatusBadge extends StatelessWidget {
  final RequestStatus status;

  const RequestStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case RequestStatus.menunggu:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        label = 'Menunggu Ketua';
        break;
      case RequestStatus.disetujui:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        label = 'Disetujui';
        break;
      case RequestStatus.ditolak:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        label = 'Ditolak';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
