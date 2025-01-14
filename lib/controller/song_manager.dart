import 'package:app_nghe_nhac/controller/controller_song.dart';
import 'package:app_nghe_nhac/model/songs.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class SongManager extends GetxController {
  static SongManager get instance => Get.find();

  final AudioPlayer audioPlayer = AudioPlayer();
  var isPlaying = false.obs;
  var isLoading = true.obs;
  var currentSong = Rxn<SongSnapshot>();
  var currentPosition = Duration.zero.obs;

  void play(SongSnapshot song) async {
    if (currentSong.value?.song.id != song.song.id) {
      await audioPlayer.play(UrlSource(song.song.url!));
      currentSong.value = song;
    } else if (!isPlaying.value) {
      await audioPlayer.resume();
    }
    isPlaying.value = true;
  }

  void pause() async {
    await audioPlayer.pause();
    isPlaying.value = false;
  }

  void stop() async {
    await audioPlayer.stop();
    isPlaying.value = false;
    currentSong.value = null;
  }

  void nextSong() {
    var playlist = ControllerSong.instance.dsbh;
    var currentIndex = playlist.indexWhere(
            (songSnap) => songSnap.song.id == currentSong.value?.song.id);
    if (currentIndex != -1 && currentIndex < playlist.length - 1) {
      play(playlist[currentIndex + 1]);
    } else {
      stop();
    }
  }

  void previous() {
    var playlist = ControllerSong.instance.dsbh;
    var currentIndex = playlist.indexWhere(
            (songSnap) => songSnap.song.id == currentSong.value?.song.id);
    if (currentIndex > 0) {
      play(playlist[currentIndex - 1]);
    }
  }


  void resume() async{
    await audioPlayer.resume();
    isPlaying.value = true;
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  void saveCurrentPosition(Duration position) {
    currentPosition.value = position;
  }

  Duration? getCurrentPosition() {
    return currentPosition.value;
  }

  Stream<Duration> get onPositionChanged => audioPlayer.onPositionChanged;
  Stream<PlayerState> get onPlayerStateChanged => audioPlayer.onPlayerStateChanged;
  Stream<void> get onPlayerComplete => audioPlayer.onPlayerComplete;
}