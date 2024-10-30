import 'dart:io';
import 'package:animation/bussiness_logic/bloc/chat_bloc.dart';
import 'package:animation/constants/colors.dart';
import 'package:animation/constants/functions.dart';
import 'package:animation/constants/strings.dart';
import 'package:animation/data/Model/chatmodel.dart';
import 'package:animation/data/Model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllChatsScreen extends StatefulWidget {
  const AllChatsScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<AllChatsScreen> createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<ChatModel> filteredChats = [];
  List<ChatModel> allChats = [];
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatBloc>(context).add(FetchAllChats());
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
      padding: const EdgeInsets.only(left: 5, bottom: 15, right: 15),
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
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: white,
              ),
            ),
            _profileImage(),
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
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: white,
                size: 30,
              )),
          suffixIcon: InkWell(
            child: const Icon(
              Icons.cancel_outlined,
              color: teal,
            ),
            onTap: () {
              _searchController.text.isEmpty
                  ? Navigator.pop(context)
                  : _clearSearch();
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
          filteredChats = allChats
              .where((element) =>
                  element.chatname.toLowerCase().contains(value.toLowerCase()))
              .toList();
          setState(() {});
        },
      ),
    );
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
        child: _buildBlocWidget(),
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
      radius: 22,
    );
  }

  Widget _titleTextWidget() {
    return const Text(
      "All Chats",
      style: TextStyle(
        fontSize: 35,
        color: white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildIcon() {
    return IconButton(
      onPressed: () {
        _startSearch();
      },
      icon: const Icon(
        Icons.search_outlined,
        color: white,
        size: 25,
      ),
    );
  }

  Widget _buildBlocWidget() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return _buildLoadingWidget();
        } else if (state is ChatLoaded) {
          if (state.chats.isEmpty) {
            return _buildEmptyPageWidget();
          }

          return _buildListViewWidget();
        } else if (state is ChatError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ConstantFuncs().showErrorDialog(context, state.error);
          });
          return const SizedBox.shrink();
        }
        return const SizedBox();
      },
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
      stream: FirebaseFirestore.instance.collection('chats').snapshots(),
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

        List<ChatModel> chats = snapshot.data!.docs.map((doc) {
          return ChatModel(
            chatid: doc.id,
            chatimageurl: doc['chatimage'],
            chatname: doc['chatname'],
            adminid: doc['admin_id'],
            lastMessage: doc['last_message'],
            membersIds: doc['members_ids']
          );
        }).toList();
        allChats = chats;
        if (_isSearching && filteredChats.isEmpty) {
          return _buildEmptyPageWidget();
        }
        return ListView.builder(
          itemCount: _isSearching ? filteredChats.length : chats.length,
          itemBuilder: (context, index) {
            ChatModel chat = _isSearching ? filteredChats[index] : chats[index];
            return Card(
              elevation: 1,
              color: lightGrey,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: chat.chatimageurl.isNotEmpty
                        ? NetworkImage(chat.chatimageurl)
                        : const AssetImage('assets/images/avatar.png')
                            as ImageProvider,
                    radius: 30,
                  ),
                  title: Text(
                    chat.chatname,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(chat.lastMessage),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      messages,
                      arguments: {
                        'chat': chat,
                        'user': widget.user,
                        'isgroup':true
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
