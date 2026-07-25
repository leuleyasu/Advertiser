import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

class AuthUserChanged extends AuthEvent {
  final User? user;
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmittedEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmittedEvent extends AuthEvent {
  final String email;
  final String password;
  final String companyName;
  final String contactName;

  const RegisterSubmittedEvent({
    required this.email,
    required this.password,
    required this.companyName,
    required this.contactName,
  });

  @override
  List<Object?> get props => [email, password, companyName, contactName];
}

class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}
