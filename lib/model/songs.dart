import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String id;
  final String title;
  final String album;
  final String artist;
  final String? url;
  final String? image;

  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.url,
    required this.image,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      album: json['album'],
      artist: json['artist'],
      url: json['url'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'title': this.title,
      'album': this.album,
      'artist': this.artist,
      'url': this.url,
      'image': this.image,
    };
  }
}

class SongSnapshot {
  final Song song;
  final DocumentReference ref;

  SongSnapshot({required this.song, required this.ref});

  factory SongSnapshot.fromMap(DocumentSnapshot docSnap) {
    return SongSnapshot(
      song: Song.fromJson(docSnap.data() as Map<String, dynamic>),
      ref: docSnap.reference,
    );
  }

  static Future<DocumentReference> themMoi(Song song) async {
    return FirebaseFirestore.instance.collection("Songs").add(song.toJson());
  }

  Future<void> capNhat(Song song) async {
    return ref.update(song.toJson());
  }

  Future<void> xoa(Song song) async {
    return ref.delete();
  }

  // Truy vấn dữ liệu thời gian thực
  static Stream<List<SongSnapshot>> getAll() {
    Stream<QuerySnapshot> sqs =
    FirebaseFirestore.instance.collection("Songs").snapshots();
    return sqs.map(
          (qs) => qs.docs.map(
                  (docSnap) => SongSnapshot.fromMap(docSnap)).toList(),
    );
  }

  // Truy vấn dữ liệu một lần
  static Future<List<SongSnapshot>> getAll2() async {
    QuerySnapshot qs = await FirebaseFirestore.instance.collection("Songs").get();
    return qs.docs.map((docSnap) => SongSnapshot.fromMap(docSnap)).toList();
  }
}