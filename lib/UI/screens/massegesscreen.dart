import 'dart:io';
import 'package:animation/UI/widgets/mybutton.dart';
import 'package:animation/bussiness_logic/bloc/chat_bloc.dart';
import 'package:animation/bussiness_logic/bloc/user_bloc.dart';
import 'package:animation/constants/colors.dart';
import 'package:animation/data/Model/usermodel.dart';
import 'package:animation/gen/assets.gen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animation/bussiness_logic/bloc/messages_bloc.dart';
import 'package:animation/data/Model/chatmodel.dart';
import 'package:animation/data/Model/messagemodel.dart';
import 'package:uuid/uuid.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class MessagesScreen extends StatefulWidget {
  final ChatModel chat;
  final UserModel user;
  final bool isGroup;

  const MessagesScreen({
    super.key,
    required this.chat,
    required this.user,
    required this.isGroup,
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final Uuid uuid = const Uuid();
  List<UserModel>? allUsers;
  bool showEmojiPicker = false;
  final FocusNode _focusNode = FocusNode();
  bool _isKeyboardVisible = false;
  UserModel? member;
  bool _memberLoaded = false; // Flag to track if the member has been loaded

  @override
  void initState() {
    super.initState();

    // Fetch the member only if it's not a group chat and hasn't been loaded yet
    if (!widget.isGroup && !_memberLoaded) {
      String memberId =
          widget.chat.membersIds.firstWhere((id) => id != widget.user.id);
      BlocProvider.of<UserBloc>(context).add(LoadUser(memberId));
      _memberLoaded = true; // Set the flag to true
    }

    // Fetch all users in any case
    BlocProvider.of<UserBloc>(context).add(FetchAllUsers());

    _focusNode.addListener(() {
      setState(() {
        _isKeyboardVisible = _focusNode.hasFocus;
        if (_isKeyboardVisible) {
          showEmojiPicker = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose(); // Dispose of the message controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is AllUsersLoaded) {
          setState(() {
            allUsers = state.users;
          });
        } else if (state is UserLoaded) {
          member = state.user;
          setState(() {
            // Member is now loaded, you can use member data
          });
        }
      },
      child: Scaffold(
        backgroundColor: grey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: teal,
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          titleTextStyle: const TextStyle(
              color: white, fontSize: 22, fontWeight: FontWeight.bold),
          iconTheme: const IconThemeData(color: white),
          actions: const [
            Icon(Icons.phone_outlined, size: 30),
            SizedBox(width: 5),
            Icon(Icons.video_call_outlined, size: 30),
            SizedBox(width: 5),
            Icon(Icons.more_vert, size: 30),
          ],
          leadingWidth: 99,
          toolbarHeight: 70,
          leading: Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 5),
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back)),
                const SizedBox(width: 10),
                widget.isGroup
                    ? CircleAvatar(
                        backgroundImage: widget.chat.chatimageurl.isNotEmpty
                            ? NetworkImage(widget.chat.chatimageurl)
                            : null,
                        radius: 25,
                      )
                    : member != null
                        ? _profileImage(member!)
                        : const CircularProgressIndicator(),
              ],
            ),
          ),
          title: widget.isGroup
              ? Text(widget.chat.chatname)
              : member != null
                  ? Text(member!.name)
                  : const Text("Loading..."),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: Assets.images.chatbackground.image().image,
            ),
          ),
          child: Column(
            children: [
              Expanded(child: _buildMessagesList()),
              isMember() ? _buildMessageInputField() : _joinChatWidget(),
              if (showEmojiPicker)
                SizedBox(
                  height: 300,
                  child: EmojiPicker(
                    onEmojiSelected: (Category, emoji) {
                      _messageController.text += emoji.emoji;
                    },
                    config: const Config(
                      emojiViewConfig: EmojiViewConfig(),
                      bottomActionBarConfig:
                          BottomActionBarConfig(enabled: false),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _joinChatWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
      child: MyButton(
        onPressed: () {
          BlocProvider.of<ChatBloc>(context)
              .add(JoinChat(widget.chat, widget.user));
          widget.chat.membersIds.add(widget.user.id);
          setState(() {});
        },
        style: true,
        child: const Text(
          "Join Chat",
          style: TextStyle(
              color: black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  bool isMember() {
    return widget.chat.membersIds.contains(widget.user.id);
  }

  Widget _buildMessagesList() {
    String chatCollection = widget.isGroup ? "chats" : "personalchats";
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(chatCollection)
          .doc(widget.chat.chatid)
          .collection('messages')
          .orderBy('sendingTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }

        final messages = snapshot.data!.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList();

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildMessageContainer(message);
          },
        );
      },
    );
  }

  Widget _profileImage(UserModel user) {
    return CircleAvatar(
      backgroundImage: user.image != null && user.image!.path.isNotEmpty
          ? FileImage(File(user.image!.path))
          : user.imageurl != null && user.imageurl!.isNotEmpty
              ? NetworkImage(user.imageurl!)
              : const AssetImage("assets/images/avatar.png") as ImageProvider,
      radius: 25,
    );
  }

  Widget _buildMessageContainer(MessageModel message) {
    bool isSentByMe = message.senderId == widget.user.id;

    UserModel? sender = allUsers?.firstWhere(
      (element) => element.id == message.senderId,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Align(
        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isSentByMe && sender != null) _buildSenderInfo(sender),
            _buildMessageBubble(message, isSentByMe),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                "${message.sendingTime.hour} : ${message.sendingTime.minute}",
                style: const TextStyle(fontSize: 12, color: black),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Extracted method for sender info
  Widget _buildSenderInfo(UserModel sender) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: sender.image != null && sender.image!.path.isNotEmpty
              ? FileImage(File(sender.image!.path))
              : sender.imageurl != null && sender.imageurl!.isNotEmpty
                  ? NetworkImage(sender.imageurl!)
                  : const AssetImage("assets/images/avatar.png")
                      as ImageProvider,
          radius: 18,
        ),
        const SizedBox(width: 5),
        Text(
          sender.name,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isSentByMe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: isSentByMe ? Colors.teal : lightGrey,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(15),
          topRight: const Radius.circular(15),
          bottomLeft: isSentByMe ? const Radius.circular(15) : Radius.zero,
          bottomRight: isSentByMe ? Radius.zero : const Radius.circular(15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              message.message,
              style: TextStyle(
                color: isSentByMe ? Colors.black : darkTeal,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: darkTeal,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                showEmojiPicker = !showEmojiPicker;
              });
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              cursorColor: darkTeal,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: lightGrey,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: darkTeal,
              size: 30,
            ),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                String messageId = uuid.v4();

                MessageModel newMessage = MessageModel(
                  id: messageId,
                  senderId: widget.user.id,
                  message: _messageController.text,
                  sendingTime: DateTime.now(),
                );
                BlocProvider.of<MessagesBloc>(context)
                    .add(SendMessage(widget.chat, newMessage, widget.isGroup));
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
