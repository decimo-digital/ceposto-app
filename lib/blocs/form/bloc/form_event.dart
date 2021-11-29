part of 'form_bloc.dart';

abstract class FormEvent extends Equatable {
  const FormEvent();
}

class EmailChangedEvent extends FormEvent {
  final String email;

  EmailChangedEvent(this.email);

  @override
  List<Object> get props => [email];
}

class PasswordChangedEvent extends FormEvent {
  final String password;

  PasswordChangedEvent(this.password);

  @override
  List<Object> get props => [password];
}
