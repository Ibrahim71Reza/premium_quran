import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/playlist_service.dart';
import '../../core/services/surah_service.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/models/surah.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/mini_player.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final String playlistName;
  const PlaylistDetailScreen({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistProvider);
    final surahIds = playlists[playlistName] ?? [];
    final allSurahs = ref.watch(surahListProvider).value ?? [];
    final currentSurah = ref.watch(currentSurahProvider).value;

    final surahMap = {for (final s in allSurahs) s.id: s};
    final playlistSurahs = surahIds
        .map((id) => surahMap[id])
        .whereType<Surah>()
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          playlistName,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger),
              onPressed: () {
                ref.read(playlistProvider.notifier).deletePlaylist(playlistName);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Playlist deleted'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.premiumBackgroundGradient,
        ),
        child: playlistSurahs.isEmpty
            ? const Center(
                child: Text(
                  "No Surahs in this playlist.",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: AppColors.goldGlowGradient,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.library_music_rounded,
                                  color: AppColors.background,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      playlistName,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${playlistSurahs.length} Surahs',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(audioQueueManagerProvider)
                                        .playQueueList(
                                          playlistSurahs,
                                          initialIndex: 0,
                                        );
                                  },
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: AppColors.background,
                                  ),
                                  label: const Text(
                                    'Play All',
                                    style: TextStyle(
                                      color: AppColors.background,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.emerald,
                                    foregroundColor: AppColors.background,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(audioQueueManagerProvider)
                                        .playQueueList(
                                          playlistSurahs,
                                          initialIndex: 0,
                                          shuffle: true,
                                        );
                                  },
                                  icon: const Icon(
                                    Icons.shuffle_rounded,
                                    color: AppColors.emerald,
                                  ),
                                  label: const Text(
                                    'Shuffle',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.emerald,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: playlistSurahs.length,
                      itemBuilder: (context, index) {
                        final surah = playlistSurahs[index];
                        final isThisSurahActive = currentSurah?.id == surah.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isThisSurahActive
                                ? AppColors.surfaceSoft
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isThisSurahActive
                                  ? AppColors.goldAccent.withOpacity(0.30)
                                  : Colors.white.withOpacity(0.04),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: isThisSurahActive
                                    ? AppColors.emeraldGlowGradient
                                    : null,
                                color: isThisSurahActive
                                    ? null
                                    : AppColors.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  surah.id.toString(),
                                  style: TextStyle(
                                    color: isThisSurahActive
                                        ? AppColors.background
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              surah.nameEn,
                              style: TextStyle(
                                color: isThisSurahActive
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              surah.nameBn,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline_rounded,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                ref
                                    .read(playlistProvider.notifier)
                                    .removeSurahFromPlaylist(
                                      playlistName,
                                      surah.id,
                                    );
                              },
                            ),
                            onTap: () {
                              final player = ref.read(audioPlayerProvider);
                              if (isThisSurahActive) {
                                if (player.playing) {
                                  player.pause();
                                } else {
                                  player.play();
                                }
                              } else {
                                ref
                                    .read(audioQueueManagerProvider)
                                    .playQueueList(
                                      playlistSurahs,
                                      initialIndex: index,
                                    );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}