import 'package:cloud_firestore/cloud_firestore.dart';

class Album {
  final String id;
  final String imageAlbum;
  final String titleAlbum;

  Album({required this.id, required this.imageAlbum, required this.titleAlbum});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageAlbum': imageAlbum,
      'titleAlbum': titleAlbum,
    };
  }

  factory Album.fromJson(Map<String, dynamic> map) {
    return Album(
      id: map['id'] as String,
      imageAlbum: map['imageAlbum'] as String,
      titleAlbum: map['titleAlbum'] as String,
    );
  }
}

class AlbumSnapshot{
  Album album;
  DocumentReference ref;

  AlbumSnapshot({required this.album, required this.ref});

  Map<String, dynamic> toMap() {
    return {
      'album': album,
      'ref': ref,
    };
  }

  factory AlbumSnapshot.fromMap(DocumentSnapshot docSnap) {
    return AlbumSnapshot(
      album: Album.fromJson(docSnap.data() as Map<String, dynamic>),
      ref: docSnap.reference,
    );
  }

  static Stream<List<AlbumSnapshot>> getAll(){
    Stream<QuerySnapshot> sqs = FirebaseFirestore.instance.collection("Album").snapshots();
    return sqs.map(
            (qs) => qs.docs.map(
                (docSnap) => AlbumSnapshot.fromMap(docSnap)
        ).toList());
  }
}