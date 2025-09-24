import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';


class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  String? _userId;

  UserModel? get user => _user;
  String? get userId => _userId;


  Future<void> initializeUser() async {
    _user = await _authService.loadPersistentUser();
    notifyListeners();
  }


  Future signIn(String email, String password) async {
    UserModel? user  = await _authService.signInWithEmailAndPassword(email, password);

    // Fill the model with the logged user infos
    if (user != null) {
      _user = user;
      _userId = user.uid;
    }
    notifyListeners();
  }


  Future register(String email, String password) async {
    _user = await _authService.registerWithEmailAndPassword(email, password);

    notifyListeners();
  }


  Future signOut() async {
    await _authService.signOut();
    await const FlutterSecureStorage().delete(key: 'uid');
    _user = null;

    notifyListeners();
  }
}