import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'quran_api_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;

  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  // State for the current playing ayah to update UI listeners
  final ValueNotifier<int?> currentSurah = ValueNotifier(null);
  final ValueNotifier<int?> currentAyah = ValueNotifier(null);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<bool> isBuffering = ValueNotifier(false);
  final ValueNotifier<ProcessingState> processingState = ValueNotifier(ProcessingState.idle);

  AudioService._internal() {
    _player.setAudioSource(_playlist);

    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isBuffering.value = state.processingState == ProcessingState.buffering || 
                          state.processingState == ProcessingState.loading;
      processingState.value = state.processingState;
      
      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
      }
    });

    _player.currentIndexStream.listen((index) async {
       if (index != null && index > 0) {
           if (currentSurah.value == null || currentAyah.value == null) return;
           int s = currentSurah.value!;
           int a = currentAyah.value! + 1;
           if (a > getVerseCount(s)) { 
             s++; 
             a = 1; 
           }
           
           if (s <= 114) {
             currentSurah.value = s;
             currentAyah.value = a;
             
             int nextS = s;
             int nextA = a + 1;
             if (nextA > getVerseCount(nextS)) { 
               nextS++; 
               nextA = 1; 
             }
             if (nextS <= 114) {
               final url = await QuranApiService.getAyahAudioUrl(nextS, nextA);
               if (url != null) {
                 final fullUrl = url.startsWith('http') ? url : "https://mirrors.quranicaudio.com/everyayah/$url";
                 await _playlist.add(AudioSource.uri(Uri.parse(fullUrl)));
               }
             }
           }
       }
    });

    _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace st) {

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
      await _playlist.clear();
      currentSurah.value = surah;
      currentAyah.value = ayah;

      final url = await QuranApiService.getAyahAudioUrl(surah, ayah);
      if (url != null) {
        final fullUrl = url.startsWith('http') ? url : "https://mirrors.quranicaudio.com/everyayah/$url";
        await _playlist.add(AudioSource.uri(Uri.parse(fullUrl)));
        
        await _player.seek(Duration.zero, index: 0);
        _player.play();
      }
    } catch (e) {
      // ignore
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

      
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      // ignore empty catch
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