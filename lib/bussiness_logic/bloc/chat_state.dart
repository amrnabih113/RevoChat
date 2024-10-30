part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatModel> chats;

  ChatLoaded(this.chats);
}

class PersonalChatLoaded extends ChatState {
  final List<ChatModel> chats;

  PersonalChatLoaded(this.chats);
}

class ChatError extends ChatState {
  final String error;

  ChatError(this.error);
}
