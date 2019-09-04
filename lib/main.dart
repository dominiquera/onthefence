import 'package:flutter/material.dart';
import 'package:onthefence/screens/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'onthefence',
      theme: ThemeData(
        primaryColor: Color(0xFF191e23),
        accentColor: Color(0xFFe94828),
      ),
      home: DefaultTabController(

        length: 4,
        child: HomePage(title: 'onthefence'),

      )
    );
  }
}

