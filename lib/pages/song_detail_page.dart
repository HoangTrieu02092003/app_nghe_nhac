import 'package:app_nghe_nhac/controller/controller_account.dart';
import 'package:app_nghe_nhac/controller/song_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../model/songs.dart';


class SongDetailPage extends StatefulWidget {
  final Song song;

  SongDetailPage({required this.song});

  @override
  _SongDetailPageState createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;
  bool _isSeeking = false; // Flag to check if the user is seeking

  void _saveCurrentPosition(Duration position) {
    SongManager.instance.saveCurrentPosition(position);
  }

  void _resumeFromSavedPosition() async {
    Duration? savedPosition = SongManager.instance.getCurrentPosition();
    if (savedPosition != null) {
      await _audioPlayer.seek(savedPosition);
      _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _saveCurrentPosition(_audioPlayer.position);
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = Get.put(AudioPlayer(), permanent: true); // Use Get.put to manage AudioPlayer
    _playlist = ConcatenatingAudioSource(
      children: [
        AudioSource.uri(Uri.parse(widget.song.url!)),
      ],
    );
    _audioPlayer.setAudioSource(_playlist).then((_) {
      _resumeFromSavedPosition();
    });

    // Listen to song change events
    SongManager.instance.currentSong.listen((songSnapShot) {
      if (songSnapShot != null && songSnapShot.song.id != widget.song.id) {
        _audioPlayer.setAudioSource(
          ConcatenatingAudioSource(
            children: [AudioSource.uri(Uri.parse(songSnapShot.song.url!))],
          ),
        ).then((_) {
          _audioPlayer.play();
        });
      }
    });

    // Listen to position changes to avoid overlapping playbacks
    _audioPlayer.positionStream.listen((position) {
      if (_isSeeking) {
        return; // Ignore updates while seeking
      }
      if (_audioPlayer.playing) {
        _saveCurrentPosition(position);
      }
    });
  }

  Stream<Duration?> get _durationStream => _audioPlayer.durationStream;
  Stream<Duration> get _positionStream => _audioPlayer.positionStream;
  Stream<Duration> get _bufferedPositionStream => _audioPlayer.bufferedPositionStream;

  Stream<PositionData> get _positionDataStream => Rx.combineLatest3<Duration?, Duration, Duration, PositionData>(
    _durationStream,
    _positionStream,
    _bufferedPositionStream,
        (duration, position, bufferedPosition) => PositionData(
      duration ?? Duration.zero,
      position,
      bufferedPosition,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Obx(() => Text(SongManager.instance.currentSong.value?.song.title ?? widget.song.title, style: TextStyle(color: Colors.white))),
        actions: [
          IconButton(
            icon: Icon(
              AccountController.instance.isFavorite(widget.song.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: AccountController.instance.isFavorite(widget.song.id)
                  ? Colors.red
                  : Colors.grey,
            ),
            onPressed: () {
              if (AccountController.instance.isFavorite(widget.song.id)) {
                AccountController.instance.removeFavorite(widget.song.id);
              } else {
                AccountController.instance.addFavorite(widget.song.id);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.grey[900]!],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              var song = SongManager.instance.currentSong.value?.song ?? widget.song;
              return song.image != null
                  ? Container(
                width: 300.0,
                height: 300.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  image: DecorationImage(
                    image: NetworkImage(song.image!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : SizedBox.shrink();
            }),
            SizedBox(height: 30.0),
            Obx(() {
              var song = SongManager.instance.currentSong.value?.song ?? widget.song;
              return Column(
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    song.artist,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white70,
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 40.0),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return Column(
                  children: [
                    Slider(
                      min: 0.0,
                      max: positionData?.duration.inMilliseconds.toDouble() ?? 1.0,
                      value: positionData?.position.inMilliseconds.toDouble() ?? 0.0,
                      onChanged: (value) {
                        _isSeeking = true;
                        _audioPlayer.seek(Duration(milliseconds: value.round())).then((_) {
                          _isSeeking = false;
                        });
                        _audioPlayer.pause();
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(positionData?.position ?? Duration.zero),
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          _formatDuration(positionData?.duration ?? Duration.zero),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  iconSize: 64.0,
                  color: Colors.white,
                  onPressed: () {
                    SongManager.instance.previous();
                  },
                ),
                IconButton(
                  icon: Obx(() => Icon(
                      SongManager.instance.isPlaying.value ? Icons.pause : Icons.play_arrow)),
                  iconSize: 64.0,
                  color: Colors.white,
                  onPressed: () {
                    if (SongManager.instance.isPlaying.value) {
                      SongManager.instance.pause();
                    } else {
                      SongManager.instance.resume();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  iconSize: 64.0,
                  color: Colors.white,
                  onPressed: () {
                    SongManager.instance.nextSong();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class PositionData {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;

  PositionData(this.duration, this.position, this.bufferedPosition);
}
