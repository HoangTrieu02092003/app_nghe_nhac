import 'package:app_nghe_nhac/controller/controller_account.dart';
import 'package:app_nghe_nhac/controller/song_manager.dart';
import 'package:app_nghe_nhac/model/account.dart';
import 'package:app_nghe_nhac/model/album.dart';
import 'package:app_nghe_nhac/model/songs.dart';
import 'package:app_nghe_nhac/pages/album_page.dart';
import 'package:app_nghe_nhac/pages/login_page.dart';
import 'package:app_nghe_nhac/pages/song_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text('Trang Chủ', style: TextStyle(color: Colors.black)),
        actions: [
          Obx(() {
            var currentAccount = AccountController.instance.currentAccount.value;
            if (currentAccount != null) {
              return IconButton(
                color: Colors.white,
                icon: Icon(Icons.logout),
                onPressed: () {
                  AccountController.instance.logout();
                },
              );
            } else {
              return IconButton(
                color: Colors.white,
                icon: Icon(Icons.login),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageLogin()), // Redirect to LoginPage
                  );
                },
              );
            }
          })
        ],
      ),
      body: Obx(() {
        var currentAccount = AccountController.instance.currentAccount.value;
        if (currentAccount == null) {
          return _buildGuestView(context);
        } else {
          return _buildUserView(context, currentAccount);
        }
      }),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Album hot',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Danh sách Playlist
            StreamBuilder<List<AlbumSnapshot>>(
              stream: AlbumSnapshot.getAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Không có album nào.');
                }
                var albums = snapshot.data!;
                return Container(
                  height: 150.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: albums.length,
                    itemBuilder: (BuildContext context, int index) {
                      var album = albums[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlbumDetailPage(album: album),
                            ),
                          );
                        },
                        child: Container(
                          width: 150.0,
                          margin: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: NetworkImage(album.album.imageAlbum),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),//Album
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Nhạc thịnh hành',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Danh sách bài hát
            StreamBuilder<List<SongSnapshot>>(
              stream: SongSnapshot.getAll(),
              builder: (context, snapshot) {
                if(snapshot.hasError)
                  return Center(child: Text("Có lỗi!!", style: TextStyle(color: Colors.red),),);
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                var songs = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    var songSnapShot = songs[index];
                    return ListTile(
                      leading: Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(songSnapShot.song.image!),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      title: Text(songSnapShot.song.title),
                      subtitle: Text('${songSnapShot.song.artist}'),
                      trailing: Obx(() {
                        var isFavorite = AccountController.instance.isFavorite(songSnapShot.song.id);
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            if (AccountController.instance.currentAccount.value != null) {
                              // Kiểm tra người dùng đã đăng nhập hay chưa
                              if (isFavorite) {
                                AccountController.instance.removeFavorite(songSnapShot.song.id);
                              } else {
                                AccountController.instance.addFavorite(songSnapShot.song.id);
                              }
                            } else {
                              // Hiển thị hộp thoại cảnh báo yêu cầu đăng nhập
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Yêu cầu đăng nhập"),
                                    content: Text("Bạn cần đăng nhập để thêm vào danh sách yêu thích."),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => PageLogin()), // Redirect to LoginPage
                                          );
                                        },
                                        child: Text("Đăng nhập"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Đóng hộp thoại cảnh báo
                                        },
                                        child: Text("Đóng"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        );

                      }),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SongDetailPage(song: songSnapShot.song,)),
                        );
                        if (SongManager.instance.currentSong.value?.song.id != songSnapShot.song.id) {
                          SongManager.instance.play(songSnapShot);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
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

  Widget _buildUserView(BuildContext context, AccountSnapshot account) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${account.account.nameUser}',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Album hot',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                StreamBuilder<List<AlbumSnapshot>>(
                  stream: AlbumSnapshot.getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('Không có album nào.');
                    }
                    var albums = snapshot.data!;
                    return Container(
                      height: 150.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: albums.length,
                        itemBuilder: (BuildContext context, int index) {
                          var album = albums[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlbumDetailPage(album: album),
                                ),
                              );
                            },
                            child: Container(
                              width: 150.0,
                              margin: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  image: NetworkImage(album.album.imageAlbum),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Danh sách bài hát',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                StreamBuilder<List<SongSnapshot>>(
                  stream: SongSnapshot.getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return Center(
                        child: Text(
                          "Có lỗi!!",
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    var songs = snapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        var songSnapShot = songs[index];
                        return ListTile(
                          leading: Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(songSnapShot.song.image!),
                                fit: BoxFit.cover,
                              ),
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          title: Text(songSnapShot.song.title),
                          subtitle: Text(
                              '${songSnapShot.song.artist}'),
                          trailing: IconButton(
                            icon: Icon(
                              AccountController.instance.isFavorite(songSnapShot.song.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: AccountController.instance.isFavorite(songSnapShot.song.id)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              if (AccountController.instance.isFavorite(songSnapShot.song.id)) {
                                AccountController.instance.removeFavorite(songSnapShot.song.id);
                              } else {
                                AccountController.instance.addFavorite(songSnapShot.song.id);
                              }
                            },
                          ),
                          onTap: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SongDetailPage(
                                      song: songSnapShot.song)),
                            );

                            if (SongManager.instance.currentSong.value?.song.id != songSnapShot.song.id) {
                              SongManager.instance.play(songSnapShot);
                            }
                            AccountController.instance.addHistory(songSnapShot.song.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
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
                    AccountController.instance.addHistory(SongManager.instance.currentSong.value!.song.id);
                    SongManager.instance.previous();
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
                    AccountController.instance.addHistory(SongManager.instance.currentSong.value!.song.id);
                    SongManager.instance.nextSong();
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
}
