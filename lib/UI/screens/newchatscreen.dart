import 'dart:io';
import 'package:animation/bussiness_logic/bloc/chat_bloc.dart';
import 'package:animation/bussiness_logic/bloc/user_bloc.dart';
import 'package:animation/constants/colors.dart';
import 'package:animation/constants/functions.dart';
import 'package:animation/constants/strings.dart';
import 'package:animation/data/Model/chatmodel.dart';
import 'package:animation/data/Model/usermodel.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final Uuid uuid = const Uuid();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<UserModel> filteredContacts = [];
  List<UserModel> allContacts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserBloc>(context).add(FetchAllUsers());
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
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
        _titleTextWidget(),
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
          icon: IconButton(
            icon: const Icon(Icons.arrow_back, color: white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.cancel_outlined, color: teal),
            onPressed: () {
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
        onChanged: (value) => _filterChats(value),
      ),
    );
  }

  void _filterChats(String query) {
    filteredContacts = allContacts
        .where((element) =>
            element.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {});
  }

  void _startSearch() {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    filteredContacts = allContacts;
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
      filteredContacts = allContacts;
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildAddGroupWidget(),
              const Padding(
                padding: EdgeInsets.only(left: 10, top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Select a contact",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              _buildBlocWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlocWidget() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return _buildLoadingWidget();
        } else if (state is AllUsersLoaded) {
          if (state.users.isEmpty) {
            return _buildEmptyPageWidget();
          }
          allContacts =
              state.users.where((user) => user.id != widget.user.id).toList();
          return _buildListViewWidget(allContacts);
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

  Widget _buildAddGroupWidget() {
    return InkWell(
      onTap: () {
       
      },
      child: ListTile(
        title: const Text(
          "New Group",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const CircleAvatar(
          radius: 22,
          backgroundColor: teal,
          child: Icon(
            Icons.group_add_outlined,
            color: white,
          ),
        ),
        tileColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: teal, width: 1),
        ),
      ),
    );
  }

  Widget _titleTextWidget() {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: white,
            )),
        const Text(
          "New Chat",
          style: TextStyle(
            fontSize: 35,
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Row(
      children: [
        _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: white,
                ),
              )
            : const SizedBox.shrink(),
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

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(color: darkTeal),
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

  Widget _buildListViewWidget(List<UserModel> users) {
    return Expanded(
      child: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ChatLoaded) {
            setState(() {
              _isLoading = false;
            });
            Navigator.pushReplacementNamed(
              context,
              messages,
              arguments: {
                'chat': state.chats[0],
                'user': widget.user,
                'isgroup': false
              },
            );
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 0),
          itemCount: _isSearching ? filteredContacts.length : users.length,
          itemBuilder: (context, index) {
            UserModel user =
                _isSearching ? filteredContacts[index] : users[index];
            if (_isSearching && filteredContacts.isEmpty) {
              return _buildEmptyPageWidget();
            }
            return ListTile(
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
                ChatModel newchat = ChatModel(
                    chatid: uuid.v1(),
                    chatimageurl: user.imageurl ?? '',
                    chatname: user.name,
                    adminid: user.id,
                    lastMessage: '',
                    membersIds: [user.id, widget.user.id]);
                BlocProvider.of<ChatBloc>(context).add(StartChat(newchat));
              },
            );
          },
        ),
      ),
    );
  }
}
