import 'dart:io';

import 'package:animation/bussiness_logic/bloc/auth_bloc.dart';
import 'package:animation/constants/colors.dart';
import 'package:animation/data/Model/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List settingsItems = [];

  @override
  void initState() {
    super.initState();
    settingsItems = [
      {
        "title": "Edit Profile",
        "icon": Icons.mode_edit_outlined,
        "ontap": () {}
      },
      {"title": "Blocked Users", "icon": Icons.block},
      {"title": "Privacy Policy", "icon": Icons.privacy_tip_outlined},
      {"title": "Delete Account", "icon": Icons.delete_outline, "ontap": () {}},
      {
        "title": "Log Out",
        "icon": Icons.exit_to_app_rounded,
        "ontap": _logout,
      },
    ];
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Logging Out',
          ),
          titleTextStyle: TextStyle(color: darkTeal, fontSize: 24),
          content: Text(message),
          contentTextStyle: TextStyle(fontSize: 18, color: grey),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'cancel',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            TextButton(
              onPressed: () =>
                  BlocProvider.of<AuthBloc>(context).add(LogOutRequest()),
              child: const Text(
                'log out',
                style: TextStyle(fontSize: 16, color: teal),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    showErrorDialog("Are you sure ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(gradient: gradientTeal2),
        child: Column(
          children: [
            _buildTopPageWidget(),
            Expanded(
              child: _buildBodyPageWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPageWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _titleTextWidget(),
        ],
      ),
    );
  }

  Widget _buildBodyPageWidget() {
    return Container(
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildUserDetailsWidget(),
          _buildListViewWidget(),
          
        ],
      ),
    );
  }

  Widget _buildListViewWidget() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: settingsItems.length,
        itemBuilder: (context, index) {
          return _buildListTileWidget(settingsItems[index]);
        },
      ),
    );
  }

  Widget _profileImage() {
    return CircleAvatar(
      backgroundImage: widget.user.image != null &&
              widget.user.image!.path.isNotEmpty
          ? FileImage(File(widget.user.image!.path))
          : widget.user.imageurl != null && widget.user.imageurl!.isNotEmpty
              ? NetworkImage(widget.user.imageurl!)
              : const AssetImage("assets/images/avatar.png") as ImageProvider,
      radius: 40,
    );
  }

  Widget _buildUserDetailsWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      child: Row(
        children: [
          _profileImage(),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(widget.user.email),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListTileWidget(item) {
    return InkWell(
      onTap: item["ontap"],
      child: ListTile(
        leading: Icon(
          item["icon"],
          color: darkTeal,
        ),
        title: Text(item['title']),
        
        trailing: Icon(
          Icons.arrow_forward_ios_outlined,
          color: medTeal,
        ),
      ),
    );
  }

  Widget _titleTextWidget() {
    return const Text(
      "Settings",
      style: TextStyle(
        fontSize: 35,
        color: white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
