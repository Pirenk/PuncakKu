import 'package:flutter/material.dart';
import '../../state/pendaki_state.dart';
import 'checklist_screen.dart';
import 'kelompok_screen.dart';
import 'permintaan_screen.dart';
import 'rencana_pendakian_screen.dart';

class PersiapanHubScreen extends StatelessWidget {
  final PendakiState state;

  const PersiapanHubScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        // Enforce rule: Group checklist cannot be opened before group is confirmed via "Buat Kelompok"
        if (state.isGroupMode &&
            !state.isGroupConfirmed &&
            state.currentSubScreen == PersiapanSubScreen.checklist) {
          return KelompokScreen(state: state);
        }

        Widget activeScreen;
        switch (state.currentSubScreen) {
          case PersiapanSubScreen.rencana:
            activeScreen = RencanaPendakianScreen(state: state);
            break;
          case PersiapanSubScreen.kelompok:
            activeScreen = KelompokScreen(state: state);
            break;
          case PersiapanSubScreen.checklist:
            activeScreen = ChecklistScreen(state: state);
            break;
          case PersiapanSubScreen.permintaan:
            activeScreen = PermintaanScreen(state: state);
            break;
        }

        // If in group mode and group is confirmed, provide the sub-navigation bar
        // for seamless access between Checklist, Kelompok, and Permintaan!
        if (state.isGroupMode &&
            state.isGroupConfirmed &&
            state.currentSubScreen != PersiapanSubScreen.rencana) {
          return Scaffold(
            body: Column(
              children: [
                _buildGroupSubNav(context),
                Expanded(child: activeScreen),
              ],
            ),
          );
        }

        return activeScreen;
      },
    );
  }

  Widget _buildGroupSubNav(BuildContext context) {
    const primaryDark = Color(0xFF1B4D3E);
    final current = state.currentSubScreen;
    final pendingCount = state.pendingChangeRequestCount;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8, bottom: 4, left: 16, right: 16),
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _buildSubNavTab(
                label: 'Checklist',
                icon: Icons.checklist_rounded,
                isSelected: current == PersiapanSubScreen.checklist,
                onTap: () => state.navigateToSubScreen(PersiapanSubScreen.checklist),
                primaryDark: primaryDark,
              ),
              _buildSubNavTab(
                label: 'Kelompok',
                icon: Icons.groups_outlined,
                isSelected: current == PersiapanSubScreen.kelompok,
                onTap: () => state.navigateToSubScreen(PersiapanSubScreen.kelompok),
                primaryDark: primaryDark,
              ),
              _buildSubNavTab(
                label: 'Permintaan',
                icon: Icons.swap_horiz_rounded,
                badgeCount: pendingCount,
                isSelected: current == PersiapanSubScreen.permintaan,
                onTap: () => state.navigateToSubScreen(PersiapanSubScreen.permintaan),
                primaryDark: primaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubNavTab({
    required String label,
    required IconData icon,
    int? badgeCount,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? primaryDark : Colors.grey.shade600,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? primaryDark : Colors.grey.shade700,
                ),
              ),
              if (badgeCount != null && badgeCount > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
