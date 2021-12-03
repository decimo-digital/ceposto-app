import 'package:ceposto/blocs/login/bloc/login_bloc.dart';
import 'package:ceposto/respository/respository.dart';
import 'package:flutter/material.dart';
import 'package:ceposto/blocs/login/bloc/login_bloc.dart' as B;
import 'package:flutter_bloc/flutter_bloc.dart';

class Welcome extends StatelessWidget {
  final UserRepository userRepository;

  Welcome({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _onLoginButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(
        LoginButtonPressed(
          email: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }

    return BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Login failed."),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) => Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.all(0),
                                child: Image.asset(
                                  'images/CePosto.png',
                                  height: 350,
                                )),
                            _email(),
                            _password(),
                            Container(
                              padding: const EdgeInsets.all(15),
                              child: ElevatedButton(
                                onPressed: _onLoginButtonPressed,
                                child: const Text('Accedi'),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(2))),
                              ),
                            ),
                          ]),
                    ))));
  }

  Widget _email() => Container(
        padding: EdgeInsets.all(15),
        child: TextField(
          style: TextStyle(color: Colors.black),
          obscureText: false,
          decoration: InputDecoration(
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            labelText: 'Email',
          ),
        ),
      );

  Widget _password() => Container(
        padding: const EdgeInsets.all(15),
        child: TextField(
          obscureText: true,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Password',
          ),
        ),
      );

  /* Widget _loginButton() => Container(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton(
          onPressed: _onLoginButtonPressed,
          child: const Text('Accedi'),
          style: ElevatedButton.styleFrom(
              primary: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2))),
        ),
      );*/

}
