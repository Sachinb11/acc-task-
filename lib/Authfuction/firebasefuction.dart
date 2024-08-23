import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(String email, String username, String mobile, String password, String uid) async {
    try {
      await _db.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'mobile': mobile,
        'password': password,
      });
    } catch (e) {
      print(e);
    }
  }
}
