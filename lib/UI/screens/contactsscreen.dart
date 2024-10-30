import 'dart:io';
import 'package:animation/bussiness_logic/bloc/user_bloc.dart';
import 'package:animation/constants/colors.dart';
import 'package:animation/constants/functions.dart';
import 'package:animation/data/Model/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<UserModel> filteredUsers = [];
  List<UserModel> allUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = [];
    allUsers = [];
    BlocProvider.of<UserBloc>(context).add(FetchAllUsers());
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
            _buildBodyWidget(),
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
        children: [_isSearching ? _buildSearchWidget() : _buildTitleWidget()],
      ),
    );
  }

  Widget _buildSearchWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search contacts ...",
          hintStyle: TextStyle(color: grey),
          icon: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: white,
              size: 30,
            ),
          ),
          suffixIcon: InkWell(
            child: const Icon(
              Icons.cancel_outlined,
              color: teal,
            ),
            onTap: () {
              if (_searchController.text.isEmpty) {
                Navigator.pop(context);
              } else {
                _clearSearch();
              }
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: white,
        ),
        onChanged: (value) {
          setState(() {
            filteredUsers = allUsers
                .where((element) =>
                    element.name.toLowerCase().contains(value.toLowerCase()))
                .toList();
          });
        },
      ),
    );
  }

  void _startSearch() {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching = true;
      filteredUsers = allUsers;
    });
  }

  void _stopSearching() {
    _clearSearch();
    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      filteredUsers = allUsers;
    });
  }

  Widget _buildTitleWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _titleTextWidget(),
        _buildIcon(),
      ],
    );
  }

  Widget _buildBodyWidget() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: lightGrey,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: _buildBlocWidget(),
      ),
    );
  }

  Widget _profileImage(UserModel user) {
    return CircleAvatar(
      backgroundImage: user.image != null && user.image!.path.isNotEmpty
          ? FileImage(File(user.image!.path))
          : user.imageurl != null && user.imageurl!.isNotEmpty
              ? NetworkImage(user.imageurl!)
              : const AssetImage("assets/images/avatar.png") as ImageProvider,
      radius: 22,
    );
  }

  Widget _titleTextWidget() {
    return const Text(
      "Contacts",
      style: TextStyle(
        fontSize: 35,
        color: white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildIcon() {
    return IconButton(
      onPressed: _startSearch,
      icon: const Icon(
        Icons.search_outlined,
        color: white,
        size: 25,
      ),
    );
  }

  Widget _buildBlocWidget() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        print(state);
        if (state is UserLoading) {
          return _buildLoadingWidget();
        } else if (state is AllUsersLoaded) {
          allUsers = state.users;
          if (allUsers.isEmpty) {
            return _buildEmptyPageWidget();
          }

          return _buildListViewWidget(allUsers);
        } else if (state is UserError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ConstantFuncs().showErrorDialog(context, state.message);
          });
          return const SizedBox.shrink();
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(color: darkTeal),
    );
  }

  Widget _buildEmptyPageWidget() {
    return const Center(
      child: Text(
        "No Contacts available.",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildListViewWidget(List<UserModel> users) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10),
      itemCount: _isSearching ? filteredUsers.length : users.length,
      itemBuilder: (context, index) {
        UserModel user = _isSearching ? filteredUsers[index] : users[index];

        return Card(
          elevation: 1,
          color: lightGrey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: _profileImage(user),
              title: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(user.email),
              onTap: () {
                // Handle user tap here (e.g., navigate to chat or profile)
              },
            ),
          ),
        );
      },
    );
  }
}
