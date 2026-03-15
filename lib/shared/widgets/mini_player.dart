import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/audio_player_service.dart';
import '../../app/theme/app_colors.dart';
import '../../features/player/player_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSurah = ref.watch(currentSurahProvider).value;
    if (currentSurah == null) return const SizedBox.shrink();

    final isPlaying = ref.watch(isPlayingProvider).value ?? false;
    final position = ref.watch(audioPositionProvider).value ?? Duration.zero;
    final duration = ref.watch(audioDurationProvider).value ?? Duration.zero;

    final progress = duration.inMilliseconds <= 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlayerScreen(),
                fullscreenDialog: true,
              ),
            );
          },
          child: Container(
            height: 78,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.emerald,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGlowGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            currentSurah.id.toString(),
                            style: const TextStyle(
                              color: AppColors.background,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSurah.nameEn,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              currentSurah.nameBn,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.emeraldGlowGradient,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: IconButton(
                          iconSize: 30,
                          color: AppColors.background,
                          icon: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          ),
                          onPressed: () {
                            final player = ref.read(audioPlayerProvider);
                            if (isPlaying) {
                              player.pause();
                            } else {
                              player.play();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}