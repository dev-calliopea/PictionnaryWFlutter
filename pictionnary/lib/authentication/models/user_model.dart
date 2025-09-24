import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? password;
  final String? name;

  UserModel({required this.uid, required this.email, this.password, this.name});

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      uid: doc['uid'], 
      email: doc['email'],
      name: doc['name'],
    );
  }
}