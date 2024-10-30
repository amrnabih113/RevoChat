part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class FetchAllChats extends ChatEvent {}

class JoinChat extends ChatEvent {
  final ChatModel chat;
  final UserModel user;

  JoinChat(this.chat, this.user);
}

class CreateGroup extends ChatEvent {}

class StartChat extends ChatEvent {
  final ChatModel chat;
  StartChat(this.chat);
}

class DeleteChat extends ChatEvent {
  final ChatModel chat;
  final UserModel user;

  DeleteChat(this.chat, this.user);
}

class CreateChat extends ChatEvent {
  final ChatModel chat;
  CreateChat(this.chat);
}
