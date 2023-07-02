import 'package:flutter/material.dart';
import 'package:hris_apps/view/dashboard.dart';
import 'package:hris_apps/view/presensi/presensi.dart';
import 'package:hris_apps/view/profile/akun.dart';

class LayoutNavigation extends StatefulWidget {
  const LayoutNavigation({super.key});

  @override
  State<LayoutNavigation> createState() => _LayoutNavigationState();
}

class _LayoutNavigationState extends State<LayoutNavigation> {
  int _currentIndex = 0;
  final List<Widget> _children = [Dashboard(), Presensi(), Profile()];

  void onBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: _children[_currentIndex],
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromARGB(255, 219, 219, 219)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
              child: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.fact_check,
                    ),
                    label: 'Presensi',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person,
                    ),
                    label: 'Akun',
                  ),
                ],
                currentIndex: _currentIndex,
                selectedItemColor: Color(0xFF5F72E4),
                onTap: onBarTapped,
              ),
            )));
  }
}
// BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.fact_check,
//             ),
//             label: 'Presensi',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.person,
//             ),
//             label: 'Akun',
//           ),
//         ],
//         currentIndex: _currentIndex,
//         selectedItemColor: Color(0xFF5F72E4),
//         onTap: onBarTapped,
//       ),