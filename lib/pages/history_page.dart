import 'package:app_nghe_nhac/controller/controller_account.dart';
import 'package:flutter/material.dart';

import 'package:app_nghe_nhac/controller/song_manager.dart';
import 'package:app_nghe_nhac/model/songs.dart';
import 'package:app_nghe_nhac/pages/song_detail_page.dart';
import 'package:get/get.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text('Lịch sử nghe nhạc'),
      ),
      body: Obx(() {
        var currentAccount = AccountController.instance.currentAccount.value;
        if (currentAccount == null) {
          return Center(
            child: Text('Bạn chưa đăng nhập'),
          );
        }

        return StreamBuilder<List<SongSnapshot>>(
          stream: SongSnapshot.getAll(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Có lỗi!!",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            var allSongs = snapshot.data!;
            var historySongIds = currentAccount.account.historySong;
            var historySongs = allSongs.where((songSnapshot) => historySongIds.contains(songSnapshot.song.id)).toList();

            return ListView.builder(
              itemCount: historySongs.length,
              itemBuilder: (context, index) {
                var songSnapshot = historySongs[index];
                return ListTile(
                  leading: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(songSnapshot.song.image ?? 'default_image_url'),
                        fit: BoxFit.cover,
                      ),
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  title: Text(songSnapshot.song.title),
                  subtitle: Text('${songSnapshot.song.artist} - ${songSnapshot.song.album}'),
                  trailing: IconButton(
                    icon: Icon(
                      AccountController.instance.isFavorite(songSnapshot.song.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: AccountController.instance.isFavorite(songSnapshot.song.id) ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      if (AccountController.instance.isFavorite(songSnapshot.song.id)) {
                        AccountController.instance.removeFavorite(songSnapshot.song.id);
                      } else {
                        AccountController.instance.addFavorite(songSnapshot.song.id);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SongDetailPage(song: songSnapshot.song)),
                    );
                    SongManager.instance.play(songSnapshot);
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}