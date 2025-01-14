import 'package:cloud_firestore/cloud_firestore.dart';

class Account{
  String idUser;
  String nameUser;
  String pass;
  String? imageUser;
  List<String> favoriteSong;
  List<String> historySong;

  Account({required this.idUser, required this.nameUser, required this.pass, this.imageUser, required this.favoriteSong, required this.historySong});

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'nameUser': nameUser,
      'pass': pass,
      'imageUser': imageUser,
      'favoriteSong': favoriteSong,
      'historySong': historySong,
    };
  }

  factory Account.fromJson(Map<String, dynamic> map) {
    return Account(
      idUser: map['idUser'] as String,
      nameUser: map['nameUser'] as String,
      pass: map['pass'] as String,
      imageUser: map['imageUser'] as String?,
      favoriteSong: List<String>.from(map['favoriteSong']),
      historySong: List<String>.from(map['historySong']),
    );
  }
}

class AccountSnapshot{
  Account account;
  DocumentReference ref;

  AccountSnapshot({required this.account, required this.ref});

  Map<String, dynamic> toMap() {
    return {
      'account': account,
      'ref': ref,
    };
  }

  factory AccountSnapshot.fromMap(DocumentSnapshot docSnap) {
    return AccountSnapshot(
      account: Account.fromJson(docSnap.data() as Map<String, dynamic>),
      ref: docSnap.reference,
    );
  }

  static Future<DocumentReference> create(Account account){
    return FirebaseFirestore.instance.collection("Account").add(account.toJson());
  }

  static Stream<List<AccountSnapshot>> getAll(){
    Stream<QuerySnapshot> sqs = FirebaseFirestore.instance.collection("Account").snapshots();
    return sqs.map(
            (qs) => qs.docs.map(
                (docSnap) => AccountSnapshot.fromMap(docSnap)
        ).toList());
  }
}