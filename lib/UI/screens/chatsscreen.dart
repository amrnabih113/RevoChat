import 'dart:io';
import 'package:animation/UI/screens/newchatscreen.dart';
import 'package:animation/bussiness_logic/bloc/user_bloc.dart';
import 'package:animation/constants/colors.dart';
import 'package:animation/constants/strings.dart';
import 'package:animation/data/Model/chatmodel.dart';
import 'package:animation/data/Model/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<ChatModel> filteredChats = [];
  List<ChatModel> allChats = [];
  Map<String, UserModel> loadedUsers = {};
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Widget _buildTitleWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _profileImage(widget.user),
            const SizedBox(width: 15),
            _titleTextWidget(),
          ],
        ),
        _buildIcon(),
      ],
    );
  }

  Widget _buildSearchWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search chats ...",
          hintStyle: TextStyle(color: grey),
          icon: InkWell(
            onTap: _stopSearching,
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
            onTap: _clearSearch,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: white,
        ),
        onChanged: _filterChats,
      ),
    );
  }

  void _filterChats(String query) {
    filteredChats = allChats
        .where((element) =>
            element.chatname.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {});
  }

  void _startSearch() {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    filteredChats = allChats;
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearch();
    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      filteredChats = allChats;
    });
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
        child: _buildListViewWidget(),
      ),
    );
  }

  Widget _titleTextWidget() {
    return const Text(
      "Chats",
      style: TextStyle(
        fontSize: 35,
        color: white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildIcon() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NewChatScreen(user: widget.user)));
          },
          icon: const Icon(
            Icons.add,
            color: white,
            size: 25,
          ),
        ),
        IconButton(
          onPressed: _startSearch,
          icon: const Icon(
            Icons.search_outlined,
            color: white,
            size: 25,
          ),
        ),
      ],
    );
  }

  Widget _profileImage(UserModel user) {
    return CircleAvatar(
      backgroundImage: user.image != null && user.image!.path.isNotEmpty
          ? FileImage(File(user.image!.path))
          : user.imageurl != null && user.imageurl!.isNotEmpty
              ? NetworkImage(user.imageurl!)
              : const AssetImage("assets/images/avatar.png") as ImageProvider,
      radius: 30,
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(
        color: darkTeal,
      ),
    );
  }

  Widget _buildEmptyPageWidget() {
    return const Center(
      child: Text(
        "No chats available.",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildListViewWidget() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('personalchats')
          .where('members_ids', arrayContains: widget.user.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyPageWidget();
        }

        allChats = snapshot.data!.docs.map((doc) {
          return ChatModel(
            chatid: doc.id,
            chatimageurl: doc['chatimage'],
            chatname: doc['chatname'],
            adminid: doc['admin_id'],
            lastMessage: doc['last_message'],
            membersIds: List<String>.from(doc['members_ids']),
          );
        }).toList();

        Set<String> memberIds = {};
        for (var chat in allChats) {
          memberIds.addAll(chat.membersIds
              .where((id) => id != widget.user.id)
              .map((id) => id as String));
        }

        _loadUsersForMemberIds(memberIds.toList());

        return BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UsersLoaded) {
              loadedUsers.clear();
              for (UserModel user in state.users) {
                loadedUsers[user.id] = user;
              }
              return ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount:
                    _isSearching ? filteredChats.length : allChats.length,
                itemBuilder: (context, index) {
                  ChatModel chat =
                      _isSearching ? filteredChats[index] : allChats[index];
                  String memberId =
                      chat.membersIds.firstWhere((id) => id != widget.user.id);

                  if (loadedUsers.containsKey(memberId)) {
                    UserModel member = loadedUsers[memberId]!;

                    return Card(
                      elevation: 1,
                      color: lightGrey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: _profileImage(member),
                          title: Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(chat.lastMessage),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              messages,
                              arguments: {
                                'chat': chat,
                                'user': widget.user,
                                'isgroup': false,
                              },
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox
                        .shrink(); // Prevents gaps if user is not loaded yet.
                  }
                },
              );
            } else if (state is UserLoading) {
              return _buildLoadingWidget();
            } else if (state is UserError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return _buildEmptyPageWidget(); // Default fallback if no state matches
            }
          },
        );
      },
    );
  }

  void _loadUsersForMemberIds(List<String> memberIds) {
    if (memberIds.isNotEmpty) {
      BlocProvider.of<UserBloc>(context).add(LoadUsers(memberIds));
    }
  }
}
