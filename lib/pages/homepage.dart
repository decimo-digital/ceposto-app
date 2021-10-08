import 'package:flutter/material.dart';
import 'package:utilities/widgets/scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: const Text('Ceposto'),
        centerTitle: true,
      ),
    );
  }
}
