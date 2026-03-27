import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'quran_api_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;

  final AudioPlayer _player = AudioPlayer();

  // State for the current playing ayah to update UI listeners
  final ValueNotifier<int?> currentSurah = ValueNotifier(null);
  final ValueNotifier<int?> currentAyah = ValueNotifier(null);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<bool> isBuffering = ValueNotifier(false);

  AudioService._internal() {
    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isBuffering.value = state.processingState == ProcessingState.buffering || 
                          state.processingState == ProcessingState.loading;
      
      if (state.processingState == ProcessingState.completed) {
        _playNext();
      }
    });

    _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace st) {
       debugPrint('Audio player error: $e');
    });
  }

  Future<void> _playNext() async {
    if (currentSurah.value != null && currentAyah.value != null) {
      int s = currentSurah.value!;
      int a = currentAyah.value! + 1;
      
      if (s <= 114) {
        int maxAyahs = getVerseCount(s);
        if (a > maxAyahs) {
          if (s < 114) {
            s++;
            a = 1;
          } else {
            return;
          }
        }
        await playAyah(s, a);
      }
    }
  }

  /// Plays audio for a full ayah.
  Future<void> playAyah(int surah, int ayah) async {
  try {
    currentSurah.value = surah;
    currentAyah.value = ayah;

    final url = await QuranApiService.getAyahAudioUrl(surah, ayah);
    if (url != null) {
      // Use a full URL check
      final fullUrl = url.startsWith('http') ? url : "https://mirrors.quranicaudio.com/everyayah/$url";
      
      debugPrint("Playing ayah audio: $fullUrl");
      
      // Don't call await _player.stop() here; it's redundant and slow.
      // just_audio handles the transition better if you just call setUrl.
      await _player.setUrl(fullUrl);
      _player.play(); // No 'await' here to keep the UI snappy
    }
  } catch (e) {
    debugPrint("Error playing ayah audio ($surah:$ayah): $e");
  }
}
  

  /// RESTORED: Plays audio for a specific word in an ayah.
  Future<void> playWordAudio(int surah, int ayah, int wordIndex) async {
    try {
      String s = surah.toString().padLeft(3, '0');
      String a = ayah.toString().padLeft(3, '0');
      String w = wordIndex.toString().padLeft(3, '0');

      if (ayah == 0) {
        s = "001";
        a = "001";
        if (wordIndex < 1 || wordIndex > 4) w = "001";
      }

      final url = "https://audio.qurancdn.com/wbw/${s}_${a}_${w}.mp3";
      debugPrint("Playing word audio: $url");
      
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint("Error playing word audio ($surah:$ayah:$wordIndex): $e");
    }
  }

  // --- RANGE PLAYBACK ---

  void playRange(int from, int to) {
    // Starts playing the 'from' ayah.
    playAyah(currentSurah.value ?? 1, from);
  }

  // --- CONTROLS ---

  Future<void> stop() async {
    await _player.stop();
    // This part ensures the Media Player UI actually disappears
    currentAyah.value = null; 
    currentSurah.value = null;
    isPlaying.value = false;
  }

  Future<void> playNext() async => _playNext();

  Future<void> playPrevious() async {
    if (currentSurah.value != null && currentAyah.value != null) {
      int s = currentSurah.value!;
      int a = currentAyah.value! - 1;

      if (a < 1) {
        if (s > 1) {
          s--;
          a = getVerseCount(s);
        } else {
          return;
        }
      }
      await playAyah(s, a);
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seekRelative(Duration duration) async {
    final current = _player.position;
    await _player.seek(current + duration);
  }

  void dispose() {
    _player.dispose();
  }
}