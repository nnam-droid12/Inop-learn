import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inop_app/modal/teacher_model.dart';
import 'package:inop_app/screens/teacherotp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inop_app/utils/utils.dart';

class TeacherAuthProvider extends ChangeNotifier {
  bool _isTeacherSignedIn = false;
  bool get isTeacherSignedIn => _isTeacherSignedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid!;
  TeacherModel? _teacherModel;
  TeacherModel get teacherModel => _teacherModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  TeacherAuthProvider() {
    checkSignIn();
  }

  void checkSignIn() async {
    final SharedPreferences shared_preference =
        await SharedPreferences.getInstance();
    _isTeacherSignedIn =
        shared_preference.getBool("isteacher_signedin") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences shared_preference =
        await SharedPreferences.getInstance();
    shared_preference.setBool("isteacher_signedin", true);
    _isTeacherSignedIn = true;
    notifyListeners();
  }

  void TeacherSignInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TeacherOtpScreen(verificationId: verificationId)),
            );
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  // verify otp

  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);

      User? user = (await _firebaseAuth.signInWithCredential(creds)).user;

      if (user != null) {
        _uid = user.uid;
        onSuccess();
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (error) {
      showSnackBar(context, error.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("teachers").doc(_uid).get();

    if (snapshot.exists) {
      print("User exist");
      return true;
    } else {
      print("New User");
      return false;
    }
  }

  void saveTeacherDataToFirebase({
    required BuildContext context,
    required TeacherModel teacherModel,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await DateTime.now().millisecondsSinceEpoch.toString();
      teacherModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
      teacherModel.uid = _firebaseAuth.currentUser!.phoneNumber!;
      _teacherModel = teacherModel;

      await _firebaseFirestore
          .collection("teachers")
          .doc(_uid)
          .set(teacherModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future getDataFromFirestore() async {
    await _firebaseFirestore
        .collection("teachers")
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _teacherModel = TeacherModel(
        name: snapshot['name'],
        coursetitle: snapshot['coursetitle'],
        createdAt: snapshot['createdAt'],
        uid: snapshot['uid'],
        phoneNumber: snapshot['phoneNumber'],
      );
      _uid = teacherModel.uid;
    });
  }

  // Store User Data Locally

  Future saveUserDataLocally() async {
    SharedPreferences shared_preferences =
        await SharedPreferences.getInstance();
    await shared_preferences.setString(
        "teacher_model", jsonEncode(teacherModel.toMap()));
  }

  Future getTeacherDataFromSharedPreference() async {
    SharedPreferences shared_preferences =
        await SharedPreferences.getInstance();
    String data = shared_preferences.getString("teacher_model") ?? '';
    _teacherModel = TeacherModel.fromMap(jsonDecode(data));
    _uid = _teacherModel!.uid;
    notifyListeners();
  }

  Future userSignOut() async {
    SharedPreferences shared_preferences =
        await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isTeacherSignedIn = false;
    notifyListeners();
    shared_preferences.clear();
  }
}
