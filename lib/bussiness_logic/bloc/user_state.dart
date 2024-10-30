part of 'user_bloc.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserLoaded extends UserState {
  final UserModel user;
  UserLoaded(this.user);
}
final class UsersLoaded extends UserState {
  final List<UserModel> users;
  UsersLoaded(this.users);
}
final class AllUsersLoaded extends UserState {
  final List<UserModel> users;
  AllUsersLoaded(this.users);
}
final class UserUpdated extends UserState {}

final class UserError extends UserState {
  final String message;
  UserError(this.message);
}
