import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:k2e/theme.dart';

class LoginPage extends StatelessWidget {
  LoginPage() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: CompanyColors.iconLGreen,
        margin: EdgeInsets.all(64.0),
        child: IconButton(icon: Icon(Icons.vpn_key), iconSize: 48.0, onPressed: _authenticateWithGoogle)
    );
  }

  GoogleSignIn googleSignIn;
  void _authenticateWithGoogle() async {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;
//    final FirebaseUser user = await
//    widget.FirebaseAuth.signInWithGoogle(
//      accessToken: googleAuth.accessToken,
//      idToken: googleAuth.idToken,
//    );
    // do something with signed-in user
  }

}

