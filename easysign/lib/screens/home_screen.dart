import 'package:easysign/screens/items/admins.dart';
import 'package:easysign/screens/items/dashboard.dart';
import 'package:easysign/screens/items/horaires.dart';
import 'package:easysign/screens/items/parametres.dart';
import 'package:easysign/screens/items/personnel.dart';
import 'package:easysign/screens/items/rapports.dart';
import 'package:easysign/themes/app_theme.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    Dashboard(),
    Horaires(),
    Personnel(),
    Rapports(),
    Admins(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<String> _labels = [
    "Accueil",
    "Horaires",
    "Personnel",
    "Rapports",
    "Admins",
  ];

  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.calendar_month_outlined,
    Icons.group_outlined,
    Icons.report_outlined,
    Icons.person_add_outlined,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EasySign',
          style: TextStyle(
            color: Appcolors.color_3,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Appcolors.color_2,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Parametres()),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Appcolors.color_2,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: List.generate(5, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _labels[index],
          );
        }),
      ),
    );
  }
}
