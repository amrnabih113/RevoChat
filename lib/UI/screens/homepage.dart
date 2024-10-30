import 'package:animation/UI/screens/chatsscreen.dart';
import 'package:animation/UI/screens/contactsscreen.dart';
import 'package:animation/UI/screens/groupchat.dart';
import 'package:animation/UI/screens/settingsscreen.dart';
import 'package:animation/UI/widgets/mynavigationbar.dart';
import 'package:animation/bussiness_logic/bloc/user_bloc.dart';
import 'package:animation/data/Model/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});

  final UserModel user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  _setFirestTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  List<UserModel> allUsers=[];
  @override
  void initState() {
    super.initState();
    _setFirestTime();

    BlocProvider.of<UserBloc>(context).add(FetchAllUsers());
    
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ChatsScreen(user: widget.user),
      Groupchat(user: widget.user),
      const ContactsScreen(),
      SettingsScreen(user: widget.user),
    ];

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: pages[_selectedIndex],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: MyNavigationBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
