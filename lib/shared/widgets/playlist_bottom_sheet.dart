import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/playlist_service.dart';
import '../../app/theme/app_colors.dart';

class PlaylistBottomSheet extends ConsumerStatefulWidget {
  final List<int> selectedSurahIds;
  final VoidCallback onClearSelection;

  const PlaylistBottomSheet({
    super.key,
    required this.selectedSurahIds,
    required this.onClearSelection,
  });

  @override
  ConsumerState<PlaylistBottomSheet> createState() =>
      _PlaylistBottomSheetState();
}

class _PlaylistBottomSheetState extends ConsumerState<PlaylistBottomSheet> {
  final TextEditingController _playlistNameController = TextEditingController();

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  String _normalizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> _addToPlaylist(String playlistName) async {
    for (final id in widget.selectedSurahIds) {
      await ref
          .read(playlistProvider.notifier)
          .addSurahToPlaylist(playlistName, id);
    }

    widget.onClearSelection();
    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${widget.selectedSurahIds.length} Surahs to $playlistName',
        ),
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.premiumBackgroundGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Add ${widget.selectedSurahIds.length} Surahs',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Create a new playlist or add to an existing one',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _playlistNameController,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'New Playlist Name...',
                    prefixIcon: Icon(
                      Icons.music_note_rounded,
                      color: AppColors.goldAccent,
                    ),
                  ),
                  onSubmitted: (_) async {
                    final name = _normalizeName(_playlistNameController.text);
                    if (name.isEmpty) return;

                    final existingName = playlists.keys.cast<String?>().firstWhere(
                      (key) => key != null && key.toLowerCase() == name.toLowerCase(),
                      orElse: () => null,
                    );

                    if (existingName != null) {
                      await _addToPlaylist(existingName);
                    } else {
                      await ref.read(playlistProvider.notifier).createPlaylist(
                            name,
                            initialIds: widget.selectedSurahIds,
                          );

                      widget.onClearSelection();
                      if (!mounted) return;

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Created $name & added ${widget.selectedSurahIds.length} Surahs',
                          ),
                          backgroundColor: AppColors.emerald,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.emeraldGlowGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withOpacity(0.25),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add_rounded,
                    color: AppColors.background,
                  ),
                  onPressed: () async {
                    final name = _normalizeName(_playlistNameController.text);
                    if (name.isEmpty) return;

                    final existingName = playlists.keys.cast<String?>().firstWhere(
                      (key) => key != null && key.toLowerCase() == name.toLowerCase(),
                      orElse: () => null,
                    );

                    if (existingName != null) {
                      await _addToPlaylist(existingName);
                    } else {
                      await ref.read(playlistProvider.notifier).createPlaylist(
                            name,
                            initialIds: widget.selectedSurahIds,
                          );

                      widget.onClearSelection();
                      if (!mounted) return;

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Created $name & added ${widget.selectedSurahIds.length} Surahs',
                          ),
                          backgroundColor: AppColors.emerald,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: AppColors.surfaceVariant),
          if (playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Text(
                'No playlists yet.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: playlists.keys.length,
                itemBuilder: (context, index) {
                  final playlistName = playlists.keys.elementAt(index);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGlowGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.queue_music_rounded,
                          color: AppColors.background,
                        ),
                      ),
                      title: Text(
                        playlistName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        "${playlists[playlistName]!.length} Surahs",
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.emerald,
                      ),
                      onTap: () => _addToPlaylist(playlistName),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}