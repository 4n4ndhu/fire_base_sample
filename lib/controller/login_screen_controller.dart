import 'dart:developer';

import 'package:fire_base_sample/utils/app_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreenController with ChangeNotifier {
  onLogginIn(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      log(credential.user?.email.toString() ?? "no data");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        AppUtils.showOnetimeSnackbar(
            context: context,
            bg: Colors.red,
            message: 'No user found for that email.');
      } else if (e.code == 'invalid-credential') {
        AppUtils.showOnetimeSnackbar(
            context: context,
            bg: Colors.red,
            message: 'Wrong password provided for that user.');
      }
    }
  }
}
