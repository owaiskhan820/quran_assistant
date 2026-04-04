import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'quran_api_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;

  final AudioPlayer _player = AudioPlayer();


  final Map<String, int> qariMap = {
  'AbdulBaset AbdulSamad (Mujawwad)': 1,
  'AbdulBaset AbdulSamad (Murattal)': 2,
  'Abdur-Rahman as-Sudais': 3,
  'Abu Bakr al-Shatri': 4,
  'Hani ar-Rifai': 5,
  //'Mahmoud Khalil Al-Husary': 6,
  'Mishari Rashid al-`Afasy': 7,
  'Mohamed Siddiq al-Minshawi (Mujawwad)': 8,
  'Mohamed Siddiq al-Minshawi (Murattal)': 9,
  //'Sa`ud ash-Shuraym': 10,
  'Mohamed al-Tablawi': 11,
  'Mahmoud Khalil Al-Husary (Muallim)': 12,
};

  int _currentRecitationId = 7;

  // State for the current playing ayah to update UI listeners
  final ValueNotifier<int?> currentSurah = ValueNotifier(null);
  final ValueNotifier<int?> currentAyah = ValueNotifier(null);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<bool> isBuffering = ValueNotifier(false);
  final ValueNotifier<ProcessingState> processingState = ValueNotifier(ProcessingState.idle);

  AudioService._internal() {
    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isBuffering.value = state.processingState == ProcessingState.buffering || 
                          state.processingState == ProcessingState.loading;
      processingState.value = state.processingState;
      
      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
      }
    });

    _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace st) {
      debugPrint('Audio playback error: $e');
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
  Future<bool> playAyah(int surah, int ayah, {int? recitationId}) async {
    try {
      if (recitationId != null) _currentRecitationId = recitationId;
      
      // 1. Force stop current playback to avoid "stickiness"
      await _player.stop();
      
      currentSurah.value = surah;
      currentAyah.value = ayah;
      isBuffering.value = true;

      final url = await QuranApiService.getAyahAudioUrl(surah, ayah, recitationId: _currentRecitationId);
      
      if (url != null) {
        // 2. Use direct AudioSource instead of a Playlist for stability
        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(url)),
          preload: true,
        );
        _player.play();
        return true;
      } else {
        isBuffering.value = false;
        await stop();
        return false;
      }
    } catch (e) {
      debugPrint('Error playing ayah audio: $e');
      isBuffering.value = false;
      await stop();
      return false;
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

      final url = "https://audio.qurancdn.com/wbw/${s}_${a}_$w.mp3";

      // 1. Force stop current playback
      await _player.stop();
      
      // 2. Set new source with try-catch
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
        preload: true,
      );
      await _player.play();
    } catch (e) {
      debugPrint('Error playing word audio: $e');
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

  Future<void> playNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    } else {
      await _playNext();
    }
  }

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