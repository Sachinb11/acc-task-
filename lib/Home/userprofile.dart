import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String name;
  String email;
  String? photoUrl;

  UserProfile({
    required this.name,
    required this.email,
    this.photoUrl,
  });

  // Method to create UserProfile from DocumentSnapshot
  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  // Method to convert the UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
