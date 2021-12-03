import 'dart:async';

import 'package:ceposto/blocs/auth/bloc/auth_bloc.dart';
import 'package:ceposto/respository/respository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  //final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    //   @required this.authenticationBloc,
  })  : assert(userRepository != null),
        // assert(authenticationBloc != null),
        super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit.call(LoginLoading());

      try {
        final token = await userRepository.login(
          event.email,
          event.password,
        );
        //authenticationBloc.add(LoggedIn(token: token));
        emit.call(LoginInitial());
      } catch (error) {
        emit.call(LoginFailure(error: error.toString()));
      }
    });
  }
}
