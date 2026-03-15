import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'surah_service.dart';
import '../models/surah.dart';

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

AudioSource _buildSurahAudioSource(Surah surah) {
  return AudioSource.uri(
    Uri.parse('asset:///assets/audio/${surah.fileName}'),
    tag: MediaItem(
      id: surah.id.toString(),
      title: surah.nameEn,
      album: 'Premium Quran',
      artist: 'Surah ${surah.surahNo} • ${surah.nameAr}',
    ),
  );
}

ConcatenatingAudioSource _buildPlaylistSource(List<Surah> surahs) {
  return ConcatenatingAudioSource(
    useLazyPreparation: true,
    children: surahs.map(_buildSurahAudioSource).toList(),
  );
}

Future<void> _savePlaybackState(
  AudioPlayer player,
  SharedPreferences prefs,
) async {
  final index = player.currentIndex ?? 0;
  final positionSec = player.position.inSeconds;

  await prefs.setInt('last_surah_index', index);
  await prefs.setInt('last_position_sec', positionSec);
}

final playlistInitProvider = FutureProvider<void>((ref) async {
  final player = ref.watch(audioPlayerProvider);
  final surahs = await ref.watch(surahListProvider.future);
  final prefs = await SharedPreferences.getInstance();

  final playlist = _buildPlaylistSource(surahs);

  final savedIndex = prefs.getInt('last_surah_index') ?? 0;
  final savedPositionSec = prefs.getInt('last_position_sec') ?? 0;
  final safeIndex = surahs.isEmpty ? 0 : savedIndex.clamp(0, surahs.length - 1);

  await player.setAudioSource(
    playlist,
    initialIndex: safeIndex,
    initialPosition: Duration(seconds: savedPositionSec),
  );

  int lastSavedIndex = safeIndex;
  int lastSavedSecond = savedPositionSec;
  bool saveInProgress = false;

  Future<void> saveIfChanged() async {
    if (saveInProgress) return;

    final currentIndex = player.currentIndex ?? 0;
    final currentSecond = player.position.inSeconds;

    if (currentIndex == lastSavedIndex && currentSecond == lastSavedSecond) {
      return;
    }

    saveInProgress = true;
    try {
      lastSavedIndex = currentIndex;
      lastSavedSecond = currentSecond;
      await _savePlaybackState(player, prefs);
    } finally {
      saveInProgress = false;
    }
  }

  final positionSub = player.positionStream.listen((position) {
    final sec = position.inSeconds;
    if (player.playing && sec > 0 && sec % 15 == 0 && sec != lastSavedSecond) {
      unawaited(saveIfChanged());
    }
  });

  final currentIndexSub = player.currentIndexStream.listen((index) {
    if (index != null) {
      unawaited(saveIfChanged());
    }
  });

  final playerStateSub = player.playerStateStream.listen((state) {
    if (!state.playing || state.processingState == ProcessingState.completed) {
      unawaited(saveIfChanged());
    }
  });

  ref.onDispose(() {
    unawaited(saveIfChanged());
    unawaited(positionSub.cancel());
    unawaited(currentIndexSub.cancel());
    unawaited(playerStateSub.cancel());
  });
});

final currentSurahProvider = StreamProvider<Surah?>((ref) {
  final player = ref.watch(audioPlayerProvider);
  final surahsAsync = ref.watch(surahListProvider);

  return player.sequenceStateStream.map((state) {
    if (state == null || state.sequence.isEmpty) return null;

    final mediaItem = state.currentSource?.tag as MediaItem?;
    if (mediaItem == null) return null;

    final surahs = surahsAsync.value ?? [];
    for (final surah in surahs) {
      if (surah.id.toString() == mediaItem.id) return surah;
    }
    return null;
  });
});

final isPlayingProvider = StreamProvider<bool>((ref) {
  return ref.watch(audioPlayerProvider).playingStream;
});

final audioPositionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerProvider).positionStream;
});

final audioDurationProvider = StreamProvider<Duration?>((ref) {
  return ref.watch(audioPlayerProvider).durationStream;
});

final shuffleModeProvider = StreamProvider<bool>((ref) {
  return ref.watch(audioPlayerProvider).shuffleModeEnabledStream;
});

final loopModeProvider = StreamProvider<LoopMode>((ref) {
  return ref.watch(audioPlayerProvider).loopModeStream;
});

final audioQueueManagerProvider = Provider<AudioQueueManager>((ref) {
  return AudioQueueManager(ref);
});

class AudioQueueManager {
  AudioQueueManager(this.ref);

  final Ref ref;

  Future<void> playQueueList(
    List<Surah> surahs, {
    int initialIndex = 0,
    bool shuffle = false,
  }) async {
    if (surahs.isEmpty) return;

    final player = ref.read(audioPlayerProvider);
    final playlist = _buildPlaylistSource(surahs);
    final safeIndex = initialIndex.clamp(0, surahs.length - 1);

    await player.setAudioSource(
      playlist,
      initialIndex: safeIndex,
      initialPosition: Duration.zero,
    );

    if (shuffle) {
      await player.shuffle();
      await player.setShuffleModeEnabled(true);
    } else {
      await player.setShuffleModeEnabled(false);
    }

    await player.play();
  }
}