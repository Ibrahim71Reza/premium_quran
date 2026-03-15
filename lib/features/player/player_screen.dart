import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/services/audio_player_service.dart';
import '../../app/theme/app_colors.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  double? _dragValue;

  String _formatDuration(Duration? duration) {
    if (duration == null) return "00:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds"
        .replaceFirst("00:", "");
  }

  @override
  Widget build(BuildContext context) {
    final currentSurah = ref.watch(currentSurahProvider).value;
    final isPlaying = ref.watch(isPlayingProvider).value ?? false;
    final position = ref.watch(audioPositionProvider).value ?? Duration.zero;
    final duration = ref.watch(audioDurationProvider).value ?? Duration.zero;
    final isShuffleMode = ref.watch(shuffleModeProvider).value ?? false;
    final loopMode = ref.watch(loopModeProvider).value ?? LoopMode.off;

    if (currentSurah == null) {
      return const Scaffold(backgroundColor: AppColors.background);
    }

    final maxSeconds =
        duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0;
    final sliderValue =
        (_dragValue ?? position.inSeconds.toDouble()).clamp(0.0, maxSeconds);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 34),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.premiumBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFF1E293B),
                              Color(0xFF111827),
                              Color(0xFF0B101A),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.goldAccent.withOpacity(0.24),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emerald.withOpacity(0.14),
                              blurRadius: 35,
                              spreadRadius: 6,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.30),
                              blurRadius: 30,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                currentSurah.nameAr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 54,
                                  color: AppColors.goldAccent,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 42),
                      Text(
                        currentSurah.nameEn,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentSurah.nameBn,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.04),
                          ),
                        ),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.emerald,
                                inactiveTrackColor: AppColors.surfaceVariant,
                                thumbColor: AppColors.goldAccent,
                                overlayColor:
                                    AppColors.goldAccent.withOpacity(0.12),
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                              ),
                              child: Slider(
                                min: 0,
                                max: maxSeconds,
                                value: sliderValue,
                                onChanged: (value) {
                                  setState(() => _dragValue = value);
                                },
                                onChangeEnd: (value) {
                                  ref.read(audioPlayerProvider).seek(
                                        Duration(seconds: value.toInt()),
                                      );
                                  setState(() => _dragValue = null);
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(
                                      Duration(seconds: sliderValue.toInt()),
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
                  child: SafeArea(
                    top: false,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = constraints.maxWidth;

                        final bool isSmallScreen = screenWidth < 380;
                        final double sideButtonSize = isSmallScreen ? 50 : 58;
                        final double sideIconSize = isSmallScreen ? 24 : 28;
                        final double playButtonSize = isSmallScreen ? 74 : 86;
                        final double playIconSize = isSmallScreen ? 38 : 44;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _GlassIconButton(
                              size: sideButtonSize,
                              iconSize: sideIconSize,
                              icon: Icons.shuffle_rounded,
                              color: isShuffleMode
                                  ? AppColors.emerald
                                  : AppColors.textSecondary,
                              onTap: () async {
                                final player = ref.read(audioPlayerProvider);
                                if (isShuffleMode) {
                                  await player.setShuffleModeEnabled(false);
                                } else {
                                  await player.shuffle();
                                  await player.setShuffleModeEnabled(true);
                                }
                              },
                            ),
                            _GlassIconButton(
                              size: sideButtonSize,
                              iconSize: sideIconSize,
                              icon: Icons.skip_previous_rounded,
                              color: AppColors.textPrimary,
                              onTap: () {
                                final player = ref.read(audioPlayerProvider);
                                if (player.hasPrevious) {
                                  player.seekToPrevious();
                                }
                              },
                            ),
                            GestureDetector(
                              onTap: () {
                                final player = ref.read(audioPlayerProvider);
                                if (isPlaying) {
                                  player.pause();
                                } else {
                                  player.play();
                                }
                              },
                              child: Container(
                                width: playButtonSize,
                                height: playButtonSize,
                                decoration: BoxDecoration(
                                  gradient: AppColors.emeraldGlowGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.emerald.withOpacity(0.30),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: playIconSize,
                                  color: AppColors.background,
                                ),
                              ),
                            ),
                            _GlassIconButton(
                              size: sideButtonSize,
                              iconSize: sideIconSize,
                              icon: Icons.skip_next_rounded,
                              color: AppColors.textPrimary,
                              onTap: () {
                                final player = ref.read(audioPlayerProvider);
                                if (player.hasNext) {
                                  player.seekToNext();
                                }
                              },
                            ),
                            _GlassIconButton(
                              size: sideButtonSize,
                              iconSize: sideIconSize,
                              icon: loopMode == LoopMode.one
                                  ? Icons.repeat_one_rounded
                                  : Icons.repeat_rounded,
                              color: loopMode == LoopMode.all
                                  ? AppColors.emerald
                                  : loopMode == LoopMode.one
                                      ? AppColors.goldAccent
                                      : AppColors.textSecondary,
                              onTap: () async {
                                final player = ref.read(audioPlayerProvider);
                                if (loopMode == LoopMode.off) {
                                  await player.setLoopMode(LoopMode.all);
                                } else if (loopMode == LoopMode.all) {
                                  await player.setLoopMode(LoopMode.one);
                                } else {
                                  await player.setLoopMode(LoopMode.off);
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
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

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 58,
    this.iconSize = 28,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: color, size: iconSize),
        ),
      ),
    );
  }
}