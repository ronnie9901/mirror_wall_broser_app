import 'package:flutter/material.dart';
import 'package:mirror_wall_broser_app/view/Homepage.dart';
import 'package:provider/provider.dart';

import 'controller/controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
        ChangeNotifierProvider(
        create: (context) => SearchProvider(),
    ),
    ],child :MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ));
  }
}


