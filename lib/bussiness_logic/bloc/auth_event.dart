part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AppStarted extends AuthEvent {}

final class LogInRequist extends AuthEvent {
  final String email;
  final String password;

  LogInRequist(this.email, this.password);
}

final class RegisterRequist extends AuthEvent {
  final String username;
  final String email;
  final String password;

  RegisterRequist(this.email, this.username, this.password);
}

final class AddUser extends AuthEvent {
  final UserModel user;
  AddUser(this.user);
}

final class VerficationRequist extends AuthEvent {
  final User user;
  VerficationRequist(this.user);
}

final class GoogleLoginRequest extends AuthEvent {}

final class LogOutRequest extends AuthEvent {}

final class AuthCheckStatus extends AuthEvent {}
