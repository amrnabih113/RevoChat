part of 'user_bloc.dart';

@immutable
sealed class UserEvent {}

class LoadUser extends UserEvent {
  final String id;
  LoadUser(this.id);
}
class LoadUsers extends UserEvent {
  final List<String> ids;
  LoadUsers(this.ids);
}

class FetchAllUsers extends UserEvent {}

class UpdateUser extends UserEvent {
  final UserModel user;
  UpdateUser(this.user);
}

class UploadProfileImage extends UserEvent {
  final XFile profileImage;
  UploadProfileImage(this.profileImage);
}
