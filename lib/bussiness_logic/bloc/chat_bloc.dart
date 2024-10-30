// chat_bloc.dart

import 'package:animation/data/Model/chatmodel.dart';
import 'package:animation/data/Model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<FetchAllChats>((event, emit) async {
      emit(ChatLoading());
      try {
        Query chatsQuery = FirebaseFirestore.instance.collection('chats');
        QuerySnapshot querySnapshot = await chatsQuery.get();
        List<ChatModel> allChats = [];

        for (var document in querySnapshot.docs) {
          allChats.add(ChatModel.chatModelFromDocument(document));
        }

        emit(ChatLoaded(allChats));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });
  on<StartChat>((event, emit) async {
  emit(ChatLoading());
  try {
    // Step 1: Query Firestore for chats that contain the admin id
    final querySnapshot = await FirebaseFirestore.instance
        .collection('personalchats')
        .where('members_ids', arrayContains: event.chat.adminid)
        .get();

    // Step 2: Filter results to ensure both members are present
    final existingChats = querySnapshot.docs.where((doc) {
      final membersIds = List<String>.from(doc['members_ids']);
      // Check if both members are present
      return membersIds.contains(event.chat.membersIds[0]) && membersIds.contains(event.chat.membersIds[0]);
    }).toList();

    // If a chat with both members exists, load it
    if (existingChats.isNotEmpty) {
      final existingChatDoc = existingChats.first;
      ChatModel existingChat = ChatModel.chatModelFromDocument(existingChatDoc);
      
      emit(ChatLoaded([existingChat]));
      return; // Exit early if chat already exists
    }

    // If no existing chat was found, create a new chat
    String newChatId = FirebaseFirestore.instance.collection('personalchats').doc().id; // Generate a new ID
    await FirebaseFirestore.instance
        .collection('personalchats')
        .doc(newChatId) // Use the generated ID here
        .set({
      'admin_id': event.chat.adminid,
      'chatimage': event.chat.chatimageurl,
      'chatname': event.chat.chatname,
      'last_message': event.chat.lastMessage,
      'members_ids': event.chat.membersIds,
    });

    // Update the event.chat with the new ID if needed
    event.chat.chatid = newChatId;

    emit(ChatLoaded([event.chat]));
  } catch (e) {
    emit(ChatError(e.toString()));
  }
});



    on<CreateChat>((event, emit) async {
      emit(ChatLoading());
      try {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(event.chat.chatid)
            .set({
          'admin_id': event.chat.adminid,
          'chatimage': event.chat.chatimageurl,
          'chatname': event.chat.chatname,
          'last_message': event.chat.lastMessage,
          'members_ids': event.chat.membersIds,
        });
        emit(ChatLoaded([event.chat]));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });

    on<JoinChat>((event, emit) async {
      emit(ChatLoading());
      try {
        DocumentReference chatRef = FirebaseFirestore.instance
            .collection('chats')
            .doc(event.chat.chatid);
        await chatRef.update({
          'members_ids': FieldValue.arrayUnion([event.user.id])
        });
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });
  }
}
