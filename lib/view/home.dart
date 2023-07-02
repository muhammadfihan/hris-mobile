import 'package:flutter/material.dart';
import 'package:hris_apps/view/navigation/bottom_nav.dart';

class MainHome extends StatelessWidget {
  const MainHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LayoutNavigation(),
      ),
    );
  }
}
