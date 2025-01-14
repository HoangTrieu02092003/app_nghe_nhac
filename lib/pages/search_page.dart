import 'package:app_nghe_nhac/controller/controller_account.dart';
import 'package:app_nghe_nhac/controller/song_manager.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../model/songs.dart';
import 'song_detail_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  Future<List<SongSnapshot>>? _searchResults;

  void _searchSongs(String query) {
    setState(() {
      _searchResults = _fetchSearchResults(query);
    });
  }



  Future<List<SongSnapshot>> _fetchSearchResults(String query) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Songs')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return querySnapshot.docs
        .map((doc) => SongSnapshot.fromMap(doc))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text('Tìm kiếm bài hát', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                ),
                hintText: 'Nhập tên bài hát',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchSongs(_searchController.text);
                  },
                ),
              ),
              onSubmitted: _searchSongs,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SongSnapshot>>(
              future: _searchResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không tìm thấy kết quả nào.'));
                }
                var songs = snapshot.data!;
                return ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    var song = songs[index].song;
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
                      subtitle: Text(
                          '${song.artist}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SongDetailPage(
                                  song: song)),
                        );
                        SongManager.instance.play(songs[index]);
                        AccountController.instance.addHistory(songs[index].song.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}
