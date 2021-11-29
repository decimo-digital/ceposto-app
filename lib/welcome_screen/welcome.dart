import 'package:flutter/material.dart';
import 'package:ceposto/blocs/form/bloc/form_bloc.dart' as B;
import 'package:flutter_bloc/flutter_bloc.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocBuilder<B.FormBloc, B.FormState>(
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
                        _email(context, state),
                        _password(context, state),
                        _loginButton(context, state),
                      ]),
                )));
  }

  Widget _email(BuildContext context, B.FormState state) => Container(
        padding: EdgeInsets.all(15),
        child: TextField(
            style: TextStyle(color: Colors.black),
            obscureText: false,
            decoration: InputDecoration(
              errorText: !state.validEmail ? 'Email non valida' : null,
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
              labelText: 'Email',
            ),
            onChanged: context.watch<B.FormBloc>().changeEmail),
      );

  Widget _password(BuildContext context, B.FormState state) => Container(
        padding: const EdgeInsets.all(15),
        child: TextField(
          obscureText: true,
          decoration: InputDecoration(
            errorText: !state.validPassword ? 'Password non valida' : null,
            border: UnderlineInputBorder(),
            labelText: 'Password',
          ),
          onChanged: context.watch<B.FormBloc>().changePassword,
        ),
      );

  Widget _loginButton(BuildContext context, B.FormState state) => Container(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton(
          onPressed: state.validForm == true ? () {} : null,
          child: const Text('Accedi'),
          style: ElevatedButton.styleFrom(
              primary: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2))),
        ),
      );
}
