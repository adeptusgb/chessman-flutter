import 'package:flutter/material.dart';
import 'pages/navigation_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NavigationPage(),
    );
  }
}
