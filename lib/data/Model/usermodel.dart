import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UserModel {
  String id;
  String name;
  String email;
  XFile? image;
  String? imageurl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    this.imageurl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['username'] ?? '',
      email: data['email'] ?? '',
      imageurl: data['imageurl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'imageurl': imageurl,
    };
  }
}
