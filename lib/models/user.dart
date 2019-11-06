import 'package:firebase_database/firebase_database.dart';

class User {
  String key;
  int perfil;
  String userId;

  User(this.userId, this.perfil);

  User.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    userId = snapshot.value["id"],
    perfil = snapshot.value["perfil"];

  toJson() {
    return {
      "id": userId,
      "perfil": perfil,
    };
  }
}