import 'dart:io';

import 'package:app_nghe_nhac/controller/controller_album.dart';
import 'package:app_nghe_nhac/controller/controller_song.dart';
import 'package:app_nghe_nhac/pages/album_page.dart';
import 'package:app_nghe_nhac/pages/favorite_page.dart';
import 'package:app_nghe_nhac/pages/history_page.dart';
import 'package:app_nghe_nhac/pages/home_page.dart';

import 'package:app_nghe_nhac/pages/profile_page.dart';
import 'package:app_nghe_nhac/pages/search_page.dart';
import 'package:app_nghe_nhac/pages/song_detail_page.dart';
import 'package:app_nghe_nhac/widget/widget_connect_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/controller_account.dart';
import '../controller/song_manager.dart';
import '../model/account.dart';
import '../model/album.dart';
import '../model/songs.dart';
import '../storage_image_helper.dart';

class HomeConnect extends StatelessWidget {
  const HomeConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MyFirebaseConnect(
      errorMessage: "Lỗi kết nối Firebase",
      connectingMessage: "Đang kết nối",
      builder: (context) => GetMaterialApp(
         initialBinding: ControllerAlbumBidings(),
        debugShowCheckedModeBanner: false,
        home: HomeView(),
      ),);
  }
}

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int index = 0;
  String? selectedAlbumId;
  TextEditingController txtSearch = TextEditingController();
  String searchText = "";
  FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;


  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
    Get.put(SongManager());
    Get.put(ControllerSong());
    Get.put(AccountController());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context, index),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: index,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.green,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
      ),
    );
  }
  _buildBody(BuildContext context, int index) {
    switch (index) {
      case 0: return _buildHome(context);
      case 1: return _buildSearch(context);
      case 2: return _buildProfile(context);
    }
  }
}

_buildHome(BuildContext context) {
  return Scaffold(
    body: MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return HomePage();
      }
      //home: HomePage(),
    ),
  );
}

_buildSearch(BuildContext context) {
  return Scaffold(
    body: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SearchPage(),
    ),
  );
}

_buildProfile(BuildContext context) {
  return Scaffold(
    body: MaterialApp(
      debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return ProfilePage();
        }
      //home: ProfilePage(),
    ),
  );
}







