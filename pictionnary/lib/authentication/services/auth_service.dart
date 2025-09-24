import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _secureStorage = const FlutterSecureStorage();


  UserModel? _userFromFirebaseUser(User? user) {
    return user != null ? UserModel(uid: user.uid, email: user.email) : null;
  }


  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }


  Future<UserModel?> loadPersistentUser() async {
    try {
      final uid = await _secureStorage.read(key: 'uid');
      if (uid == null) return null;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data();

      return UserModel(
        uid: userData?['uid'],
        email: userData?['email'],
        name: userData?['name'],
      );
      
    } catch (e) {
      print('Error loading persistent user: $e');
      return null;
    }
  }


  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Save user uid into FlutterSecureStorage
      if (user != null) {
        await _secureStorage.write(key:'uid', value: user.uid);
      }

      return _userFromFirebaseUser(user);

    } catch (e) {
      return null;
    }
  }


  Future<UserModel?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Save user uid into FlutterSecureStorage
        await _secureStorage.write(key:'uid', value: user.uid);

        // Save user into a Firestore users collection 
        await saveUserToFirestore(user);
      }

      return _userFromFirebaseUser(user);

    } catch (e) {
      return null;
    }
  }


  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }


  Future<void> saveUserToFirestore(User? user) async {
    if (user == null) return;

    try {
      final usersRef = FirebaseFirestore.instance.collection('users');
      final userDoc = usersRef.doc(user.uid);

      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? '',
      }, SetOptions(merge: true));

    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
  }
}