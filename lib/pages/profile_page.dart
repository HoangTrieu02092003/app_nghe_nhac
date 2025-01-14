import 'package:app_nghe_nhac/controller/song_manager.dart';
import 'package:app_nghe_nhac/model/favorite.dart';
import 'package:app_nghe_nhac/model/songs.dart';
import 'package:app_nghe_nhac/pages/edit_profile_page.dart';
import 'package:app_nghe_nhac/pages/favorite_page.dart';
import 'package:app_nghe_nhac/pages/history_page.dart';
import 'package:app_nghe_nhac/pages/page_hone_music_app.dart';
import 'package:app_nghe_nhac/pages/song_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/controller_account.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final AccountController _accountController = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text('Tài khoản của bạn', style: TextStyle(color: Colors.black)),
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
      body: Center(
        child: Obx(
              () => _accountController.currentAccount.value != null
              ? buildProfileContent(context)
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 100,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Bạn chưa đăng nhập',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Vui lòng đăng nhập để tiếp tục',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PageLogin(),
                        ));
                      },
                      child: Text('Đăng nhập ngay'),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Widget buildProfileContent(BuildContext context) {
    var currentAccount = _accountController.currentAccount.value!;
    var historySongs = currentAccount.account.historySong;
    var favoriteSongs = currentAccount.account.favoriteSong;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
                currentAccount.account.imageUser ?? 'default_image_url'), // Thay bằng hình ảnh từ tài khoản
          ),
          SizedBox(height: 5),
          Text(
            currentAccount.account.nameUser, // Hiển thị tên người dùng
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditAccountPage(
                  account: currentAccount.account,
                ),
              ));
            },
            child: Text('Chỉnh sửa thông tin cá nhân'),
          ),
          SizedBox(height: 10),
          _buildSectionHeader(context, 'Nghe gần đây', HistoryPage()),
          _buildSongList(historySongs, 3),
          Divider(),
          _buildSectionHeader(context, 'Yêu thích', FavoritePage()),
          _buildSongList(favoriteSongs, 3),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Widget destinationPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destinationPage),
              );
            },
            child: Text(
              'Xem tất cả',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList(List<String> songIds, int maxCount) {
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
        var songs = allSongs.where((songSnapshot) => songIds.contains(songSnapshot.song.id)).toList();
        songs = songs.take(maxCount).toList();

        return Column(
          children: songs.map((songSnapshot) {
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SongDetailPage(song: songSnapshot.song)),
                );
                SongManager.instance.play(songSnapshot);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
