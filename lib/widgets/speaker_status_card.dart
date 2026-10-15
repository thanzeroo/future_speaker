import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/speaker_provider.dart';
import '../theme/app_theme.dart';

class SpeakerStatusCard extends StatelessWidget {
  const SpeakerStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeakerProvider>(
      builder: (context, provider, _) {
        final connected = provider.isConnected;
        final isConnecting = provider.isConnecting;
        final espIp = provider.settings.espIp;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Speaker Icon with glowing container
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: connected
                          ? AppColors.primarySurface
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.speaker_outlined,
                      color:
                          connected ? AppColors.primary : AppColors.textTertiary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FUTURE SPEAKER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textTertiary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isConnecting
                              ? 'Menghubungkan ke ESP...'
                              : (connected
                                  ? 'Speaker Online (Tersambung)'
                                  : 'Speaker Offline (Terputus)'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isConnecting
                                    ? AppColors.warning
                                    : (connected
                                        ? AppColors.online
                                        : AppColors.offline),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                isConnecting
                                    ? 'Mencari perangkat di $espIp...'
                                    : (connected
                                        ? 'Wi-Fi: $espIp · Siap digunakan'
                                        : 'Sambungkan Wi-Fi ke "FutureSpeaker"'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Settings / IP button
                  IconButton(
                    icon: const Icon(Icons.settings_ethernet_rounded, size: 22),
                    color: AppColors.primary,
                    tooltip: 'Ubah IP Wi-Fi',
                    onPressed: () => _showIpDialog(context, provider),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Action Buttons: Sambung & Restart Koneksi ──
              Row(
                children: [
                  // Tombol Sambung Koneksi
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        icon: isConnecting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(
                                connected
                                    ? Icons.check_circle_rounded
                                    : Icons.wifi_rounded,
                                size: 18),
                        label: Text(
                          isConnecting
                              ? 'Menghubungkan...'
                              : (connected ? 'Tersambung' : 'Sambung Koneksi'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: connected
                              ? AppColors.primary
                              : AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isConnecting
                            ? null
                            : () async {
                                final ok = await provider.connect();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(ok
                                          ? 'Berhasil tersambung ke Future Speaker ($espIp)!'
                                          : 'Gagal terhubung. Pastikan Wi-Fi terhubung ke "FutureSpeaker" ($espIp)'),
                                      duration: const Duration(seconds: 3),
                                      backgroundColor: ok
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Tombol Restart Koneksi
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text(
                          'Restart Koneksi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.primaryLight, width: 1.3),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isConnecting
                            ? null
                            : () async {
                                final ok = await provider.restartConnection();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(ok
                                          ? 'Koneksi berhasil di-restart & tersambung!'
                                          : 'Restart selesai, speaker belum terdeteksi di $espIp'),
                                      duration: const Duration(seconds: 3),
                                      backgroundColor: ok
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showIpDialog(BuildContext context, SpeakerProvider provider) {
    final controller = TextEditingController(text: provider.settings.espIp);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Alamat IP Future Speaker',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan IP ESP32 (Default Hotspot: 192.168.4.1 atau IP router kamu)',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '192.168.4.1',
                prefixIcon: const Icon(Icons.router_outlined,
                    color: AppColors.primary, size: 20),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final newIp = controller.text.trim();
              if (newIp.isNotEmpty) {
                provider.setEspIp(newIp);
                provider.connect(newIp);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan & Sambung'),
          ),
        ],
      ),
    );
  }
}
