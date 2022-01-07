import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:miniproject/helpers/HIveBoxDetails.dart';
import 'package:miniproject/screens/HomeScreen.dart';
import 'package:miniproject/screens/LiveScreen.dart';
import 'package:miniproject/screens/UploadScreen.dart';

import 'screens/DetailScreen.dart';

void main() async {
  await Hive.initFlutter();

  // Create a hive box, unless it already exists
  await Hive.openBox(HiveBoxDetails.hiveboxName);
  await Hive.openBox(HiveBoxDetails.prefboxName);
  // HiveBoxDetails.box.clear();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'crop detector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/homepage',
      routes: {
        '/homepage': (context) => HomeScreen(),
        '/livepage': (context) => LiveScreen(title: 'live cam'),
        '/uploadpage': (context) => UploadScreen(),
        '/detailpage': (context) => DetailScreen(),
      },
    );
  }
}
