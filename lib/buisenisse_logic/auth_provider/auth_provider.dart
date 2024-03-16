import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users/data/client_model/client.dart';
import 'package:users/presentation/widgets/my_toast/my_toast.dart';

import '../../presentation/screens/main_screen/main_screen.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Client? _client;

  Client? get client => _client;

  String _id = "";

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authResult != null) {
        _client = Client(authResult.user!.uid, authResult.user!.email!);
        showtoast("regestration succesfuly");

        final SharedPreferences prefs = await SharedPreferences.getInstance();

        _id = _client!.uid!;

        prefs.setString("id", _id);

        notifyListeners();

        Map<String, dynamic> driverMap = {
          "id": authResult.user!.uid,
          "name": name,
          "email": email,
          "phone": phone,
        };

        DatabaseReference driversRef =
            FirebaseDatabase.instance.ref().child("users");
        driversRef.child(authResult.user!.uid).set(driverMap).then((_) {
          // Data is successfully written to the database, notify listeners again.

          notifyListeners();
        }).catchError((error) {
          // Handle database write error here (e.g., show toast, log error, etc.).
          print("Error writing data to the database: $error");
          showtoast("Error writing data to the database: $error");
        });
      } else {
        showtoast("Error creating user");
      }
    } catch (e) {
      print('Error registering user: $e');

      throw e;
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authResult != null) {
        _client = Client(authResult.user!.uid, authResult.user!.email!);

        print("hello :${authResult.user!.uid}");

        DatabaseReference driverRef =
            FirebaseDatabase.instance.ref().child("users");

        driverRef.child(authResult.user!.uid).once().then(
          (data) async {
            final snap = data.snapshot;

            if (snap.value != null) {
              Navigator.of(context).pop();

              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      curve: Curves.easeIn,
                      duration: const Duration(milliseconds: 550),
                      type: PageTransitionType.leftToRight,
                      child: MainScreen()));
              showtoast("login Successful");
              notifyListeners();

              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();

              _id = _client!.uid!;

              prefs.setString("id", _id);

              notifyListeners();
            } else {
              showtoast("You are not a driver");
              Navigator.of(context).pop();
              logOut();

              notifyListeners();
            }
          },
        );
      }
    } catch (error) {
      print("message :$error");
      throw error;
    }
  }

  Future<void> logOut() async {
    _firebaseAuth.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _id = '';

    prefs.setString("id", _id);
    notifyListeners();
  }
}
