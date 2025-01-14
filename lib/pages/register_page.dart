import 'dart:io';

import 'package:app_nghe_nhac/controller/controller_account.dart';
import 'package:app_nghe_nhac/model/account.dart';
import 'package:app_nghe_nhac/storage_image_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  XFile? _xFile;
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();
  bool _hasFocus1 = false;
  bool _hasFocus2 = false;
  bool _hasFocus3 = false;
  TextEditingController _textTK = TextEditingController();
  TextEditingController _textMK = TextEditingController();
  TextEditingController _textMKT = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() {
      setState(() {
        _hasFocus1 = _focusNode1.hasFocus;
      });
    });
    _focusNode2.addListener(() {
      setState(() {
        _hasFocus2 = _focusNode2.hasFocus;
      });
    });
    _focusNode3.addListener(() {
      setState(() {
        _hasFocus3 = _focusNode3.hasFocus;
      });
    });
  }


  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Text("TẠO TÀI KHOẢN", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      child: _xFile == null?Image.network('https://inkythuatso.com/uploads/thumbnails/800/2023/03/9-anh-dai-dien-trang-inkythuatso-03-15-27-03.jpg'):Image.file(File(_xFile!.path)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 8,
                        backgroundColor: Colors.amberAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        shadowColor: Colors.black,
                      ),
                      onPressed: () async{
                        _xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if(_xFile != null){
                          setState(() {});
                        }
                      },
                      child: Text("Chọn ảnh", style: TextStyle(color: Colors.black54),),
                    ),
                  ],
                ),
                _hasFocus1 || _textTK.text.isNotEmpty?
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 30),
                  child: Text("Tên người dùng",textAlign: TextAlign.left , style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12,),),
                ):SizedBox(height: 0,),
                Padding(
                  padding: EdgeInsets.only(
                      top: _hasFocus1 || _textTK.text.isNotEmpty ? 5 : 55,
                      right: 30,
                      left: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: _hasFocus1 ? Colors.blueGrey :  Colors.grey),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TextField(
                      controller: _textTK,
                      focusNode: _focusNode1,
                      decoration: InputDecoration(
                        hintText: _hasFocus1 || _textTK.text.isNotEmpty ? '' : 'Tên người dùng',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                _hasFocus2 || _textMK.text.isNotEmpty?
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 30),
                  child: Text("Mật khẩu",textAlign: TextAlign.left , style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12,),),
                ):SizedBox(height: 0,),
                Padding(
                  padding: EdgeInsets.only(
                      top: _hasFocus2 || _textMK.text.isNotEmpty ? 5 : 55,
                      right: 30,
                      left: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: _hasFocus2 ? Colors.blueGrey :  Colors.grey),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TextField(
                      obscureText: true,
                      controller: _textMK,
                      focusNode: _focusNode2,
                      decoration: InputDecoration(
                        hintText: _hasFocus2 || _textMK.text.isNotEmpty ? '' : 'Mật khẩu',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                _hasFocus3 || _textMKT.text.isNotEmpty?
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 30),
                  child: Text("Nhập lại mật khẩu",textAlign: TextAlign.left , style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12,),),
                ):SizedBox(height: 0,),
                Padding(
                  padding: EdgeInsets.only(
                      top: _hasFocus3 || _textMKT.text.isNotEmpty ? 5 : 55,
                      right: 30,
                      left: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: _hasFocus3 ? Colors.blueGrey :  Colors.grey),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TextField(
                      obscureText: true,
                      controller: _textMKT,
                      focusNode: _focusNode3,
                      decoration: InputDecoration(
                        hintText: _hasFocus3 || _textMKT.text.isNotEmpty ? '' : 'Nhập lại mật khẩu',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 80, left: 80, top: 60),
                  child: Card(
                    color: Colors.blueAccent,
                    elevation: 0.0,
                    child: ListTile(
                      title: Text(
                        "Tạo mới", textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white
                        ),
                      ),
                      onTap: () async{
                        if(_textMK.text == _textMKT.text) {
                          String defaultImageUrl = "https://inkythuatso.com/uploads/thumbnails/800/2023/03/9-anh-dai-dien-trang-inkythuatso-03-15-27-03.jpg";
                          if (_xFile != null) {
                            try {
                              String url = await uploadImage(
                                  imagePath: _xFile!.path,
                                  folders: ["Account"],
                                  fileName: "${_textTK.text}.jpg");
                              Account ac = Account(
                                idUser: AccountController.instance.generateUniqueId(),
                                nameUser: _textTK.text,
                                pass: _textMK.text,
                                imageUser: url,
                                favoriteSong: [],
                                historySong: [],
                              );
                              AccountSnapshot.create(ac);
                              Get.snackbar("Thông báo", "Tạo thành công");
                              Navigator.of(context).pop();
                            }
                            catch (error) {
                              Get.snackbar("Lỗi", "Lỗi");
                            }
                          }
                          else{
                            Account ac = Account(
                              idUser: AccountController.instance.generateUniqueId(),
                              nameUser: _textTK.text,
                              pass: _textMK.text,
                              imageUser: defaultImageUrl,
                              favoriteSong: [],
                              historySong: [],
                            );
                            await AccountSnapshot.create(ac);
                            Get.snackbar("Thông báo", "Tạo thành công");
                            Navigator.of(context).pop();
                          }
                        }
                        else
                          Get.snackbar("Lỗi", "Mật khẩu và nhập lại mật khẩu không khớp");
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}