import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:ceposto/respository/respository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null),
        super(AuthenticationUninitialized()) {
    on<AppStarted>((event, emit) async {
      emit.call(AuthenticationUninitialized());

      AuthenticationEvent event;

      if (event is AppStarted) {
        final bool hasToken = await userRepository.hasToken();
        if (hasToken) {
          emit.call(AuthenticationAuthenticated());
        } else {
          emit.call(AuthenticationUnauthenticated());
        }
      }

      if (event is LoggedIn) {
        emit.call(AuthenticationLoading());
        await userRepository.persistToken(event.token);
        emit.call(AuthenticationLoading());
      }

      if (event is LoggedOut) {
        emit.call(AuthenticationLoading());
        await userRepository.deleteToken();
        emit.call(AuthenticationUnauthenticated());
      }
    });
  }

  /*@override
  AuthenticationState get initialState => AuthenticationUninitialized();*/
}
