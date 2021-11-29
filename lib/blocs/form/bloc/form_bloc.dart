import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'form_event.dart';
part 'form_state.dart';

class FormBloc extends Bloc<FormEvent, FormState> {
  FormBloc() : super(FormState()) {
    on<FormEvent>((event, emit) async {
      emit.call(FormState());
      FormEvent event;

      if (event is EmailChangedEvent) {
        emit.call(FormState(email: event.email, password: state.password));
      } else if (event is PasswordChangedEvent) {
        emit.call(FormState(email: state.email, password: event.password));
      }
    });
  }

  void changeEmail(String email) => add(EmailChangedEvent(email));

  void changePassword(String password) => add(PasswordChangedEvent(password));
}
