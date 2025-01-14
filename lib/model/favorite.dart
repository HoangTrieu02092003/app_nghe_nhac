class Favorite{
  String songId;
  List<String> userId;

  Favorite({required this.songId, required this.userId});

  Map<String, dynamic> toMap() {
    return {
      'songId': this.songId,
      'userId': this.userId,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      songId: map['songId'] as String,
      userId: List<String>.from(map['userId']),
    );
  }
}