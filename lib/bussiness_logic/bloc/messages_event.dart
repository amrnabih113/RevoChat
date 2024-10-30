part of 'messages_bloc.dart';

@immutable
abstract class MessagesEvent {}

class FetchMessages extends MessagesEvent {
  final ChatModel chat;
  FetchMessages(this.chat);
}

class SendMessage extends MessagesEvent {
  bool isGroup;
  final MessageModel message;
  final ChatModel chat;
  SendMessage(this.chat, this.message, this.isGroup);
}

class ReceiveMessage extends MessagesEvent {
  final ChatModel chat;
  ReceiveMessage(this.chat);
}

class DeleteMessage extends MessagesEvent {
  final MessageModel message;
  final ChatModel chat;
  DeleteMessage(this.chat, this.message);
}
