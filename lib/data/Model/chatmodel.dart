import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String chatid;
  String chatimageurl;
  String chatname;
  String adminid;
  String lastMessage;
  List membersIds;

  ChatModel({
    required this.chatid,
    required this.chatimageurl,
    required this.chatname,
    required this.adminid,
    required this.lastMessage,
    required this.membersIds
  });

  factory ChatModel.chatModelFromDocument(QueryDocumentSnapshot document) {
    return ChatModel(
        chatid: document.id,
        chatimageurl: document.get('chatimage'),
        chatname: document.get('chatname'),
        adminid: document.get('admin_id'),
        lastMessage: document.get('last_message'),
        membersIds: document.get('members_ids'));
  }
}
