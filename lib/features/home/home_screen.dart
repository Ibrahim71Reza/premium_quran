import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/surah_service.dart';
import '../../core/services/audio_player_service.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/mini_player.dart';
import '../../shared/widgets/playlist_bottom_sheet.dart';
import '../library/library_screen.dart';

final selectionProvider = StateProvider<Set<int>>((ref) => {});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahListAsyncValue = ref.watch(filteredSurahListProvider);
    ref.watch(playlistInitProvider);
    final currentSurah = ref.watch(currentSurahProvider).value;

    final selectedSurahs = ref.watch(selectionProvider);
    final isSelectionMode = selectedSurahs.isNotEmpty;
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      appBar: isSelectionMode
          ? AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () =>
                    ref.read(selectionProvider.notifier).state = {},
              ),
              title: Text(
                '${selectedSurahs.length} Selected',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.emeraldGlowGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emerald.withOpacity(0.25),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.playlist_add_rounded,
                          color: AppColors.background),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => PlaylistBottomSheet(
                            selectedSurahIds: selectedSurahs.toList(),
                            onClearSelection: () =>
                                ref.read(selectionProvider.notifier).state = {},
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          : AppBar(
              title: const Text(
                'Premium Quran',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.library_music_rounded,
                        color: AppColors.emerald,
                        size: 26,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LibraryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.premiumBackgroundGradient,
        ),
        child: Column(
          children: [
            if (!isSelectionMode) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TextField(
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (value) =>
                        ref.read(searchQueryProvider.notifier).state = value,
                    decoration: const InputDecoration(
                      hintText: 'Search by name, Arabic, Bangla or number...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.emerald,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.menu_book_rounded,
                        title: 'Total Surahs',
                        value: '114',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.tune_rounded,
                        title: 'Search',
                        value: searchQuery.trim().isEmpty ? 'All' : 'Filtered',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: surahListAsyncValue.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.emerald),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
                data: (surahs) {
                  if (surahs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Surahs found.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: surahs.length,
                    itemBuilder: (context, index) {
                      final surah = surahs[index];
                      final isThisSurahActive = currentSurah?.id == surah.id;
                      final isSelected = selectedSurahs.contains(surah.id);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.emerald.withOpacity(0.12)
                              : isThisSurahActive
                                  ? AppColors.surfaceSoft
                                  : AppColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.emerald.withOpacity(0.55)
                                : isThisSurahActive
                                    ? AppColors.goldAccent.withOpacity(0.30)
                                    : Colors.white.withOpacity(0.04),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColors.emerald.withOpacity(0.10)
                                  : Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: isSelectionMode
                              ? Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? AppColors.emerald
                                      : AppColors.textSecondary,
                                  size: 30,
                                )
                              : Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: isThisSurahActive
                                        ? AppColors.emeraldGlowGradient
                                        : null,
                                    color: isThisSurahActive
                                        ? null
                                        : AppColors.surfaceVariant,
                                    shape: BoxShape.circle,
                                    boxShadow: isThisSurahActive
                                        ? [
                                            BoxShadow(
                                              color: AppColors.emerald
                                                  .withOpacity(0.25),
                                              blurRadius: 16,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
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
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  surah.nameEn,
                                  style: TextStyle(
                                    color: isThisSurahActive || isSelected
                                        ? AppColors.textPrimary
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (isThisSurahActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.goldGlowGradient,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Playing',
                                    style: TextStyle(
                                      color: AppColors.background,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              surah.nameBn,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          trailing: Text(
                            surah.nameAr,
                            style: TextStyle(
                              color: isThisSurahActive
                                  ? AppColors.goldAccent
                                  : AppColors.textSecondary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onLongPress: () {
                            if (!isSelectionMode) {
                              ref.read(selectionProvider.notifier).state = {
                                surah.id,
                              };
                            }
                          },
                          onTap: () async {
                            if (isSelectionMode) {
                              final set = Set<int>.from(selectedSurahs);
                              if (isSelected) {
                                set.remove(surah.id);
                              } else {
                                set.add(surah.id);
                              }
                              ref.read(selectionProvider.notifier).state = set;
                            } else {
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
                                    .playQueueList(surahs, initialIndex: index);
                              }
                            }
                          },
                        ),
                      );
                    },
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.emeraldGlowGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.background, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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