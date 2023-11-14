import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users/data/client_model/client.dart';

class AssistantsService with ChangeNotifier {
  Client? client;

  Future<void> getCurrentUserInfo() async {
    final currntUser = FirebaseAuth.instance.currentUser;

    DatabaseReference dataRef =
        FirebaseDatabase.instance.ref().child("users").child(currntUser!.uid);

    dataRef.once().then((snapData) {
      if (snapData.snapshot.value != null) {
        client = Client.fromSnapshot(snapData.snapshot);
        notifyListeners();

        print("name : ${client!.name}");
        print("email : ${client!.email}");
      }
    });
  }
}
