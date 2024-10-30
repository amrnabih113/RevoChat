import 'package:animation/UI/screens/allchatsscreen.dart';
import 'package:animation/UI/screens/authScreen.dart';
import 'package:animation/UI/screens/massegesscreen.dart';
import 'package:animation/UI/screens/profilescreen.dart';
import 'package:animation/UI/screens/splashscreen.dart';
import 'package:animation/bussiness_logic/bloc/auth_bloc.dart';
import 'package:animation/bussiness_logic/bloc/chat_bloc.dart';
import 'package:animation/bussiness_logic/bloc/messages_bloc.dart';
import 'package:animation/bussiness_logic/bloc/user_bloc.dart';
import 'package:animation/data/Model/chatmodel.dart';
import 'package:animation/data/Model/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animation/UI/screens/homepage.dart';
import 'package:animation/UI/screens/onboardingscreen.dart';
import 'package:animation/constants/strings.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is AuthInitial) {
              Navigator.pushNamedAndRemoveUntil(
                  context, splash, (route) => false);
            } else if (state is AuthLoggedIn) {
              Navigator.pushNamedAndRemoveUntil(
                  context, homepage, (route) => false,
                  arguments: state.user);
            }
          },
          child: _handleRouting(settings),
        );
      },
    );
  }

  Widget _handleRouting(RouteSettings settings) {
    switch (settings.name) {
      case onboardingscreen:
        return const OnboardingScreen();
      case homepage:
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => UserBloc()),
          ],
          child: HomePage(user: settings.arguments as UserModel),
        );
      case authscreen:
        return const AuthScreen();

      case allchats:
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => ChatBloc()),
            BlocProvider(create: (context) => UserBloc()),
          ],
          child: AllChatsScreen(user: settings.arguments as UserModel),
        );
      case messages:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args.containsKey('user') &&
            args.containsKey('chat')) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => ChatBloc()),
              BlocProvider(create: (context) => MessagesBloc()),
              BlocProvider(create: (context) => UserBloc())
            ],
            child: MessagesScreen(
              user: args['user'] as UserModel,
              chat: args['chat'] as ChatModel,
              isGroup: args['isgroup'] as bool,
            ),
          );
        } else {
          return const SplashScreen();
        }
      case splash:
        return const SplashScreen();
      case profile:
        if (settings.arguments != null) {
          return BlocProvider(
            create: (context) => UserBloc(),
            child: ProfileScreen(user: settings.arguments as UserModel),
          );
        } else {
          return const SplashScreen();
        }
      default:
        return const SplashScreen();
    }
  }
}
