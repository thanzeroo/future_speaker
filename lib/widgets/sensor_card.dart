import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/speaker_provider.dart';
import '../theme/app_theme.dart';

class SensorCard extends StatelessWidget {
  const SensorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeakerProvider>(
      builder: (context, provider, _) {
        final reading = provider.sensorReading;
        final connected = provider.isConnected;
        final detected = reading.objectDetected && connected;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: detected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              // Hand icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: detected
                      ? AppColors.primarySurface
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.pan_tool_alt_outlined,
                  color: detected ? AppColors.primary : AppColors.textTertiary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: detected
                                ? AppColors.online
                                : AppColors.offline,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          detected
                              ? 'Tangan Terdeteksi'
                              : 'Menunggu Gesture',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: detected
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      reading.distanceCm < 100
                          ? '${reading.distanceCm.toStringAsFixed(1)} cm · Dual HC-SR04'
                          : 'Jangkauan bebas · Dual HC-SR04',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detected
                          ? 'Tangan siap memberi perintah gesture'
                          : 'Sensor kiri (Prev) & kanan (Play/Next)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
