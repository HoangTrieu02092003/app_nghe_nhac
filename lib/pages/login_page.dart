import 'package:app_nghe_nhac/controller/controller_account.dart';
import 'package:app_nghe_nhac/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  bool _hasFocus1 = false;
  bool _hasFocus2 = false;
  bool isValid = false;
  TextEditingController _textTK = TextEditingController();
  TextEditingController _textMK = TextEditingController();

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
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
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
          padding: const EdgeInsets.only(top: 60),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Text("ĐĂNG NHẬP",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
                ),
                _hasFocus1 || _textTK.text.isNotEmpty?
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 30),
                  child: Text("Tên người dùng",textAlign: TextAlign.left , style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12,),),
                ):SizedBox(),
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
                ):SizedBox(),
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
                Padding(
                  padding: EdgeInsets.only(right: 80, left: 80, top: 60),
                  child: Card(
                    color: Colors.blueAccent,
                    elevation: 0.0,
                    child: ListTile(
                      title: Text(
                        "Đăng nhập", textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white
                        ),
                      ),
                      onTap: () {
                        String tenText = _textTK.text;
                        String mkText = _textMK.text;
                        AccountController.instance.login(tenText, mkText);
                        setState(() {
                          isValid = AccountController.instance.currentAccount.value != null;
                        });
                        if (isValid) {
                          Get.snackbar('Thành công', 'Đăng nhập thành công');
                          Navigator.of(context).pop();
                        } else {
                          Get.snackbar('Lỗi', 'Tên người dùng hoặc mật khẩu không hợp lệ');
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Chưa có tài khoản? ", style: TextStyle(fontSize: 14, color: Colors.grey), ),
                      GestureDetector(
                        child: Text("Đăng ký", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black) ,),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Register(),));
                        },
                      ),
                    ],
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