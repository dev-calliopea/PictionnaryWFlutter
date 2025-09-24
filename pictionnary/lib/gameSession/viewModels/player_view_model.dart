import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pictionnary/authentication/models/user_model.dart';

class PlayerViewModel extends ChangeNotifier {
  List<UserModel> users = [];
  bool isLoading = false;


  Future<void> fetchUsers() async {
    isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      users = snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList(); 

    } catch (e) {
      print('Error fetching users: $e');

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
