import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animation/data/Model/usermodel.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists) {
          String userId = docSnapshot['id'] ?? '';
          String userName = docSnapshot['username'] ?? 'Unknown';
          String email = docSnapshot['email'] ?? '';
          String? imageUrl = docSnapshot['imageurl'];

          XFile? imageFile = imageUrl != null && !imageUrl.startsWith('http')
              ? XFile(imageUrl)
              : null;

          UserModel myuser = UserModel(
            id: userId,
            email: email,
            name: userName,
            image: imageFile,
            imageurl: imageUrl?.startsWith('http') == true ? imageUrl : null,
          );

          emit(AuthLoggedIn(myuser));
        } else {
          emit(AuthInitial());
        }
      } else {
        emit(AuthInitial());
      }
    });

    on<LogInRequist>((event, emit) async {
      emit(AuthLoading());
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (docSnapshot.exists) {
            String userId = docSnapshot['id'] ?? '';
            String userName = docSnapshot['username'] ?? 'Unknown';
            String email = docSnapshot['email'] ?? '';
            String? imageUrl = docSnapshot['imageurl'];

            XFile? imageFile = imageUrl != null && !imageUrl.startsWith('http')
                ? XFile(imageUrl)
                : null;

            UserModel myuser = UserModel(
              id: userId,
              email: email,
              name: userName,
              image: imageFile,
              imageurl: imageUrl?.startsWith('http') == true ? imageUrl : null,
            );

            emit(AuthLoggedIn(myuser));
          }
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<GoogleLoginRequest>((event, emit) async {
      emit(AuthLoading());
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          emit(AuthFailure("Google sign-in was canceled."));
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        User? user = userCredential.user;
        if (user != null) {
          DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!docSnapshot.exists) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'id': user.uid,
              'username': user.displayName ?? 'Anonymous',
              'email': user.email ?? '',
              'imageurl': user.photoURL ?? '',
            });
          }

          DocumentSnapshot updatedDocSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          String userId = updatedDocSnapshot['id'] ?? '';
          String userName = updatedDocSnapshot['username'] ?? 'Unknown';
          String email = updatedDocSnapshot['email'] ?? '';
          String? imageUrl = updatedDocSnapshot['imageurl'];

          XFile? imageFile = imageUrl != null && !imageUrl.startsWith('http')
              ? XFile(imageUrl)
              : null;

          UserModel myuser = UserModel(
            id: userId,
            email: email,
            name: userName,
            image: imageFile,
            imageurl: imageUrl?.startsWith('http') == true ? imageUrl : null,
          );

          emit(AuthLoggedIn(myuser));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<RegisterRequist>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        User? user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'id': user.uid,
            'username': event.username,
            'email': event.email,
            'imageurl': '',
          });

          UserModel myuser = UserModel(
            id: user.uid,
            email: event.email,
            name: event.username,
            image: null,
            imageurl: null,
          );

          emit(AuthLoggedIn(myuser));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogOutRequest>((event, emit) async {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
      emit(AuthInitial());
    });
  }
}
