class History{
  String songId;
  List<String> userId;

  History({required this.songId, required this.userId});

  Map<String, dynamic> toMap() {
    return {
      'songId': this.songId,
      'userId': this.userId,
    };
  }

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      songId: map['songId'] as String,
      userId: List<String>.from(map['userId']),
    );
  }
}