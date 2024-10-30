import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:animation/data/Model/usermodel.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<LoadUser>((event, emit) async {
      emit(UserLoading());
      try {
        print("loaded user =================");
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(event.id)
            .get();

        if (userSnapshot.exists) {
          String userId = userSnapshot['id'] ?? '';
          String userName = userSnapshot['username'] ?? '';
          String email = userSnapshot['email'] ?? '';
          String? imageUrl = userSnapshot['imageurl'];

          UserModel user;

          if (imageUrl != null && imageUrl.startsWith('http')) {
            user = UserModel(
              id: userId,
              email: email,
              name: userName,
              imageurl: imageUrl,
            );
          } else {
            user = UserModel(
              id: userId,
              email: email,
              name: userName,
              image: imageUrl != null ? XFile(imageUrl) : null,
            );
          }
          print("${user.email}");
          emit(UserLoaded(user));
        } else {
          emit(UserError("User data not found."));
        }
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
on<LoadUsers>((event, emit) async {
  emit(UserLoading());
  try {
    print("Loading users =================");

    List<UserModel> users = [];

    // Load each user in the list of IDs
    for (String userId in event.ids) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        String userId = userSnapshot['id'] ?? '';
        String userName = userSnapshot['username'] ?? '';
        String email = userSnapshot['email'] ?? '';
        String? imageUrl = userSnapshot['imageurl'];

        UserModel user;

        if (imageUrl != null && imageUrl.startsWith('http')) {
          user = UserModel(
            id: userId,
            email: email,
            name: userName,
            imageurl: imageUrl,
          );
        } else {
          user = UserModel(
            id: userId,
            email: email,
            name: userName,
            image: imageUrl != null ? XFile(imageUrl) : null,
          );
        }
        
        print("${user.email}");
        users.add(user);
      } else {
        print("User data not found for ID: $userId");
      }
    }

    emit(UsersLoaded(users)); 
  } catch (e) {
    emit(UserError(e.toString()));
  }
});

    on<FetchAllUsers>((event, emit) async {
      emit(UserLoading());
      print("===================== all user loading");
      try {
        print("===================== fetch user loading");

        QuerySnapshot allUsersSnapshot =
            await FirebaseFirestore.instance.collection('users').get();
        List<UserModel> allUsers = allUsersSnapshot.docs.map((doc) {
          String? imageUrl = doc['imageurl'];

          return imageUrl != null && imageUrl.startsWith('http')
              ? UserModel(
                  id: doc['id'] ?? '',
                  email: doc['email'] ?? '',
                  name: doc['username'] ?? '',
                  imageurl: imageUrl,
                )
              : UserModel(
                  id: doc['id'] ?? '',
                  email: doc['email'] ?? '',
                  name: doc['username'] ?? '',
                  image: imageUrl != null ? XFile(imageUrl) : null,
                );
        }).toList();

        emit(AllUsersLoaded(allUsers));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<UpdateUser>((event, emit) async {
      emit(UserLoading());
      try {
        User? firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .update({
            'username': event.user.name,
            'email': event.user.email,
            'imageurl': event.user.image != null
                ? event.user.image!.path
                : event.user.imageurl ?? '',
          });

          emit(UserUpdated());
          emit(UserLoaded(event.user));
        } else {
          emit(UserError("No user logged in."));
        }
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<UploadProfileImage>((event, emit) async {
      emit(UserLoading());
      try {
        User? firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_images/${firebaseUser.uid}');

          UploadTask uploadTask =
              storageRef.putFile(File(event.profileImage.path));
          TaskSnapshot snapshot = await uploadTask;

          String downloadUrl = await snapshot.ref.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .update({'imageurl': downloadUrl});

          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get();

          String userId = userSnapshot['id'] ?? '';
          String userName = userSnapshot['username'] ?? '';
          String email = userSnapshot['email'] ?? '';

          UserModel updatedUser = UserModel(
            id: userId,
            email: email,
            name: userName,
            imageurl: downloadUrl,
          );

          emit(UserUpdated());
          emit(UserLoaded(updatedUser));
        } else {
          emit(UserError("No user logged in."));
        }
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
  }
}
