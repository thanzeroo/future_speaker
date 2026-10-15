import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GestureGrid extends StatelessWidget {
  const GestureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // Row 1
          Row(
            children: [
              const Expanded(
                child: _GestureItem(
                  icon: Icons.pan_tool_alt_rounded,
                  action: 'Sensor Kanan 1x Tap',
                  result: 'Putar / Jeda Musik',
                ),
              ),
              Container(
                width: 1,
                height: 72,
                color: AppColors.cardBorder,
              ),
              const Expanded(
                child: _GestureItem(
                  icon: Icons.double_arrow_rounded,
                  action: 'Sensor Kanan 2x Tap',
                  result: 'Lagu Berikutnya',
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            color: AppColors.cardBorder,
          ),
          // Row 2
          Row(
            children: [
              const Expanded(
                child: _GestureItem(
                  icon: Icons.arrow_back_rounded,
                  action: 'Sensor Kiri 1x Tap',
                  result: 'Lagu Sebelumnya',
                ),
              ),
              Container(
                width: 1,
                height: 72,
                color: AppColors.cardBorder,
              ),
              const Expanded(
                child: _GestureItem(
                  icon: Icons.wifi_rounded,
                  action: 'Aplikasi / Wi-Fi',
                  result: 'Kontrol & Restart',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GestureItem extends StatelessWidget {
  final IconData icon;
  final String action;
  final String result;

  const _GestureItem({
    required this.icon,
    required this.action,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
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
