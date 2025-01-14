import 'package:app_nghe_nhac/model/songs.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class ControllerSong extends GetxController {
  var dsbh = <SongSnapshot>[].obs;
  var historyList = <SongSnapshot>[].obs;
  var currentMedia = Rxn<SongSnapshot>();
  var isPlaying = false.obs;
  AudioPlayer audioPlayer = AudioPlayer();

  static ControllerSong get instance => Get.find<ControllerSong>();


  @override
  void onReady() {
    dsbh.bindStream(SongSnapshot.getAll());
    super.onReady();
  }
}

class ControllerMediaBidings extends Bindings{

  @override
  void dependencies() {
    Get.put(ControllerSong());
  }
}