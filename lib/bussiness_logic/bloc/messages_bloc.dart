import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:animation/data/Model/chatmodel.dart';
import 'package:animation/data/Model/messagemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc() : super(MessagesInitial()) {
    on<ReceiveMessage>(_onReceiveMessage);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onReceiveMessage(
      ReceiveMessage event, Emitter<MessagesState> emit) async {
    emit(MessageLoading());
    try {
      await for (final messagesSnapshot in FirebaseFirestore.instance
          .collection('chats')
          .doc(event.chat.chatid)
          .collection('messages')
          .orderBy('sendingTime', descending: true)
          .snapshots()) {
        final messages = messagesSnapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList();

        if (messages.isEmpty) {
          emit(MessageEmpty());
        } else {
          emit(MessageLoaded(messages));
        }
      }
    } catch (error) {
      emit(MessageError(error.toString()));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<MessagesState> emit) async {
    emit(MessageSending());
    try {
      await _sendMessageToFirestore(event.chat, event.message, event.isGroup);

      await _updateLastMessage(event.chat.chatid, event.message.message,event.isGroup);

      emit(MessageSent());
    } catch (error) {
      emit(MessageError(error.toString()));
    }
  }

  Future<void> _sendMessageToFirestore(
      ChatModel chat, MessageModel message, bool isGroup) async {
    isGroup
        ? await FirebaseFirestore.instance
            .collection('chats')
            .doc(chat.chatid)
            .collection('messages')
            .doc(message.id)
            .set(message.toMap())
        : await FirebaseFirestore.instance
            .collection('personalchats')
            .doc(chat.chatid)
            .collection('messages')
            .doc(message.id)
            .set(message.toMap());
  }

  Future<void> _updateLastMessage(String chatId, String lastMessage, bool isGroup) async {
   isGroup? await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .update({'last_message': lastMessage}):await FirebaseFirestore.instance
        .collection('personalchats')
        .doc(chatId)
        .update({'last_message': lastMessage});
  }
}
