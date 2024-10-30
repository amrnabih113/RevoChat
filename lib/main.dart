import 'package:animation/app_router.dart';
import 'package:animation/bussiness_logic/bloc/auth_bloc.dart';
import 'package:animation/bussiness_logic/bloc/chat_bloc.dart';
import 'package:animation/bussiness_logic/bloc/user_bloc.dart';
import 'package:animation/data/Model/usermodel.dart';
import 'package:animation/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(
    appRouter: AppRouter(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserModel? user;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AppStarted()),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedIn) {
            user = state.user;

          }
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateRoute: widget.appRouter.generateRoute,
        ),
      ),
    );
  }
}
