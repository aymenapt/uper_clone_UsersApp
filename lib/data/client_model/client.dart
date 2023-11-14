import 'package:firebase_database/firebase_database.dart';

class Client {
  String? uid;
  String? email;
  String? phone;
  String? name;

  Client( this.uid, this.email,{this.phone, this.name});

  Client.fromSnapshot(DataSnapshot dataSnapshot) {
    phone = (dataSnapshot.value as dynamic)["phone"];
    uid = dataSnapshot.key.toString();
    email = (dataSnapshot.value as dynamic)["email"];
    name = (dataSnapshot.value as dynamic)["name"];

  }
}
