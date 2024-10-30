
part of 'messages_bloc.dart';

@immutable
abstract class MessagesState {}

class MessagesInitial extends MessagesState {}

class MessageLoading extends MessagesState {}

class MessageLoaded extends MessagesState {
  final List<MessageModel> messages;
  MessageLoaded(this.messages);
}

class MessageUpdated extends MessagesState {
  final List<MessageModel> messages;
  MessageUpdated(this.messages);
}

class MessageSending extends MessagesState {}

class MessageSent extends MessagesState {}

class MessageDeleted extends MessagesState {}

class MessageEmpty extends MessagesState {}

class MessageError extends MessagesState {
  final String error;
  MessageError(this.error);
}
