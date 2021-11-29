part of 'form_bloc.dart';

class FormState extends Equatable {
  final String email;
  final String password;

  FormState({this.email, this.password});

  bool get validEmail => email != null;

  bool get validPassword => password != null && password.length >= 6;

  bool get validForm => validEmail && validPassword;

  @override
  List<Object> get props => [email, password];
}
