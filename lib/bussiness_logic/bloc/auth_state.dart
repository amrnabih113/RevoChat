part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthLoggedIn extends AuthState {
  final UserModel user;
  AuthLoggedIn(this.user);
}

final class AuthEmailVerified extends AuthState {}

final class AuthFailure extends AuthState {
  final String errorMassege;
  AuthFailure(this.errorMassege);
}
