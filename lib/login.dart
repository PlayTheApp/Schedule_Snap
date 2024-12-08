import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schedule_snap/style.dart';
import 'Home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        // 로그인 성공
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
        return userCredential;
      } else {
        // 로그인이 취소된 경우
        throw Exception("로그인 취소");
      }
    } catch (e) {
      // 에러 캐치
      Fluttertoast.showToast(
        msg: "로그인 취소",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        fontSize: 15,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColor,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              // 로그인되지 않은 경우 로그인 화면으로 이동
              return Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Image.asset('assets/image/Login_icon.png', scale: 4.5),
                              SizedBox(height: 10),
                              Text(
                                'Schedule Snap',
                                style: TitleLine,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text("[ 서비스 이용을 위해서는 로그인이 필요합니다. ]", style: TextStyle(fontSize: 12, color: Colors.white)),
                              SizedBox(height: 15), 
                              Login_Button(signInWithGoogle), 
                              SizedBox(height: 15), 
                              Text("ⓣ mentolatos Corp.", style: TextStyle(fontSize: 12, color: Colors.white))],
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              );
            } else {
              // 로그인된 사용자가 있으면 앱 홈화면으로 이동
              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                statusBarColor: Colors.white, // 변경하려는 색상 설정
                systemNavigationBarColor: MainColor,
                systemNavigationBarDividerColor: MainColor,
                systemNavigationBarIconBrightness: Brightness.light,
              ));
              return Home();
            }
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
