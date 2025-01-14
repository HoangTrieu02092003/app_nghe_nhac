import 'package:app_nghe_nhac/controller/controller_account.dart';
import 'package:app_nghe_nhac/controller/song_manager.dart';
import 'package:app_nghe_nhac/pages/song_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../model/album.dart';
import '../model/songs.dart';

class AlbumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Albums'),
      ),
      body: StreamBuilder<List<AlbumSnapshot>>(
        stream: AlbumSnapshot.getAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<AlbumSnapshot> albums = snapshot.data!;
          return Container(
            height: 150.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: albums.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // Xử lý khi người dùng nhấp vào một album
                    _navigateToAlbumDetail(context, albums[index]);
                  },
                  child: Container(
                    width: 150.0,
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(albums[index].album.imageAlbum),
                        SizedBox(height: 8.0),
                        Text(albums[index].album.titleAlbum),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToAlbumDetail(BuildContext context, AlbumSnapshot album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumDetailPage(album: album),
      ),
    );
  }
}


class AlbumDetailPage extends StatelessWidget {
  final AlbumSnapshot album;

  const AlbumDetailPage({required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text(album.album.titleAlbum),
      ),
      body: Column(
        children: [
          Image.network(album.album.imageAlbum),
          SizedBox(height: 16.0),
          Text(
            album.album.titleAlbum,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<List<SongSnapshot>>(
              stream: getSongsByAlbum(album.album.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có bài hát nào trong album này.'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var song = snapshot.data![index].song;
                    return ListTile(
                      leading: Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(song.image!),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      title: Text(song.title),
                      subtitle: Text(song.artist),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SongDetailPage(
                                  song: snapshot.data![index].song)),
                        );
                        SongManager.instance.play(snapshot.data![index]);
                        AccountController.instance.addHistory(snapshot.data![index].song.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: Obx(() {
        if (SongManager.instance.currentSong.value == null) {
          return SizedBox.shrink();
        }
        return BottomAppBar(
          color: Colors.green[600],
          child: Container(
            color: Colors.green[200],
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongDetailPage(song: SongManager.instance.currentSong.value!.song),
                      ),
                    );
                  },
                  child:
                  Image(image: Image.network(SongManager.instance.currentSong.value!.song.image!).image, width: 40, height: 40, fit: BoxFit.cover),

                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(SongManager.instance.currentSong.value!.song.title),
                ),
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: () {
                    SongManager.instance.previous();
                    AccountController.instance.addHistory(SongManager.instance.currentSong.value!.song.id);
                  },
                ),
                IconButton(
                  icon: Icon(
                    SongManager.instance.isPlaying.value ? Icons.pause : Icons.play_arrow,
                  ),
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
                  onPressed: () {
                    SongManager.instance.nextSong();
                    AccountController.instance.addHistory(SongManager.instance.currentSong.value!.song.id);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    SongManager.instance.currentSong.value = null;
                    SongManager.instance.pause();
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Stream<List<SongSnapshot>> getSongsByAlbum(String albumId) {
    Stream<QuerySnapshot> sqs = FirebaseFirestore.instance
        .collection('Songs')
        .where('album', isEqualTo: albumId)
        .snapshots();
    return sqs.map((qs) => qs.docs.map((docSnap) => SongSnapshot.fromMap(docSnap)).toList());
  }
}


