import 'package:ceposto/pages/login.dart';
import 'package:ceposto/utils/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

void main() {
  runApp(const CePosto());
}

class CePosto extends StatelessWidget {
  const CePosto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CePosto',
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const Login(),
        ),
      ],
      theme: LightTheme.theme,
    );
  }
}
