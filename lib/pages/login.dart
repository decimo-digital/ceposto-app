import 'package:flutter/material.dart';
import 'package:utilities/widgets/button.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Text('Ceposto'),
          ),
          Expanded(
            child: Center(
              child: CustomButton.elevated(
                label: "Inizia ad usare l'app",
                onPressed: () async {},
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text('Sei un esercente?'),
                CustomButton.elevated(
                  label: 'Accedi',
                  onPressed: () async {},
                ),
                const Text('oppure'),
                CustomButton.elevated(
                  label: 'Registrati',
                  onPressed: () async {},
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
