import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../model/account.dart';

class AccountController extends GetxController{
  var dsAc = <AccountSnapshot>[].obs;
  var currentAccount = Rx<AccountSnapshot?>(null);
  static AccountController get instance => Get.find();

  @override
  void onReady() {
    dsAc.bindStream(AccountSnapshot.getAll());
    super.onReady();
  }

  void login(String tenDN, String mk) {
    var account = dsAc.firstWhereOrNull(
            (account) => account.account.nameUser == tenDN && account.account.pass == mk);
    if (account != null) {
      currentAccount.value = account;
    }
  }

  void logout() {
    currentAccount.value = null;
    Get.snackbar("Thông báo", "Đăng xuất thành công");
  }

  void addHistory(String songId) {
    if (currentAccount.value != null) {
      if (currentAccount.value!.account.historySong.length >= 20) {
        currentAccount.value!.account.historySong.removeAt(0);
      }
      currentAccount.value!.account.historySong.remove(songId);
      currentAccount.value!.account.historySong.add(songId);
      currentAccount.value!.ref.update({
        'historySong': currentAccount.value!.account.historySong
      }).then((_) {
        currentAccount.refresh();
      });
      FirebaseFirestore.instance.collection('History').doc(songId).set({
        'songId': songId,
        'userId': FieldValue.arrayUnion([currentAccount.value!.account.idUser])
      }, SetOptions(merge: true));
    }
  }

  void addFavorite(String songId) {
    if (currentAccount.value != null) {
      currentAccount.value!.account.favoriteSong.add(songId);
      currentAccount.value!.ref.update({
        'favoriteSong': currentAccount.value!.account.favoriteSong
      }).then((_) {
        currentAccount.refresh();
      });
      FirebaseFirestore.instance.collection('Favorite').doc(songId).set({
        'songId': songId,
        'userId': FieldValue.arrayUnion([currentAccount.value!.account.idUser])
      }, SetOptions(merge: true));
    }
  }

  void removeFavorite(String songId) {
    if (currentAccount.value != null) {
      currentAccount.value!.account.favoriteSong.remove(songId);
      currentAccount.value!.ref.update({
        'favoriteSong': currentAccount.value!.account.favoriteSong
      }).then((_) {
        currentAccount.refresh();
      });
      FirebaseFirestore.instance.collection('Favorite').doc(songId).update({
        'userId': FieldValue.arrayRemove([currentAccount.value!.account.idUser])
      });
    }
  }

  bool isFavorite(String songId) {
    return currentAccount.value?.account.favoriteSong.contains(songId) ?? false;
  }

  Future<void> updateAccount(Account account) async {
    try {
      await FirebaseFirestore.instance
          .collection('Account')
          .doc(account.idUser)
          .update(account.toJson());
      Get.snackbar("Thông báo", "Cập nhật tài khoản thành công");
    } catch (e) {
      //Get.snackbar("Lỗi", "Không thể cập nhật tài khoản: $e");
    }
  }


  String generateUniqueId() {
    return FirebaseFirestore.instance.collection('Account').doc().id;
  }
  // String generateUniqueId() {
  //   var timestamp = DateTime.now().millisecondsSinceEpoch;
  //   var random = Random().nextInt(100000);
  //   return '$timestamp$random';
  // }
}

class ControllerAccountBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(AccountController());
  }
}