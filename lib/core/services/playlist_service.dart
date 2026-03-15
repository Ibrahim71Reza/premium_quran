import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final playlistProvider =
    StateNotifierProvider<PlaylistNotifier, Map<String, List<int>>>((ref) {
      return PlaylistNotifier();
    });

class PlaylistNotifier extends StateNotifier<Map<String, List<int>>> {
  PlaylistNotifier() : _box = Hive.box<List>('playlistsBox'), super({}) {
    _loadPlaylists();
  }

  final Box<List> _box;

  void _loadPlaylists() {
    final loadedPlaylists = <String, List<int>>{};

    for (final key in _box.keys) {
      final rawList = _box.get(key, defaultValue: const []) ?? const [];
      loadedPlaylists[key.toString()] = rawList.cast<int>();
    }

    state = loadedPlaylists;
  }

  String _normalizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _containsNameInsensitive(String name) {
    final lower = name.toLowerCase();
    return state.keys.any((key) => key.toLowerCase() == lower);
  }

  Future<void> createPlaylist(
    String name, {
    List<int> initialIds = const [],
  }) async {
    final normalized = _normalizeName(name);

    if (normalized.isEmpty) return;
    if (normalized.length > 40) return;
    if (_containsNameInsensitive(normalized)) return;

    final uniqueIds = initialIds.toSet().toList();

    await _box.put(normalized, uniqueIds);
    state = {...state, normalized: uniqueIds};
  }

  Future<void> deletePlaylist(String name) async {
    if (!state.containsKey(name)) return;

    await _box.delete(name);

    final newState = Map<String, List<int>>.from(state);
    newState.remove(name);
    state = newState;
  }

  Future<void> addSurahToPlaylist(String playlistName, int surahId) async {
    final current = state[playlistName];
    if (current == null) return;

    if (current.contains(surahId)) return;

    final updated = [...current, surahId];
    await _box.put(playlistName, updated);
    state = {...state, playlistName: updated};
  }

  Future<void> removeSurahFromPlaylist(String playlistName, int surahId) async {
    final current = state[playlistName];
    if (current == null) return;

    final updated = List<int>.from(current)..remove(surahId);

    await _box.put(playlistName, updated);
    state = {...state, playlistName: updated};
  }
}