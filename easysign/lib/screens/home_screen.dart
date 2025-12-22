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

  // Fonction pour naviguer vers un onglet spécifique
  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EasySign',
          style: TextStyle(
            color: Appcolors.color_2,
            fontSize: 22,
            fontWeight:
                FontWeight.w500, // Si vous avez une police personnalisée
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: Appcolors.color_2,
                size: 22,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Parametres()),
                );
              },
            ),
          ),
        ],
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _selectedIndex == 0
          ? Dashboard(onNavigateToTab: _navigateToTab)
          : _getScreenForIndex(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Appcolors.color_2,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Horaires',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Personnel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_outlined),
            label: 'Rapports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_outlined),
            label: 'Admins',
          ),
        ],
      ),
    );
  }

  // Méthode pour obtenir l'écran correspondant à l'index
  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return Dashboard(onNavigateToTab: _navigateToTab);
      case 1:
        return const Horaires();
      case 2:
        return const Personnel();
      case 3:
        return const Rapports();
      case 4:
        return const Admins();
      default:
        return Dashboard(onNavigateToTab: _navigateToTab);
    }
  }
}
