import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:easysign/themes/app_theme.dart';
import 'package:easysign/screens/items/dashboard.dart';
import 'package:easysign/screens/items/horaires.dart';
import 'package:easysign/screens/items/personnel.dart';
import 'package:easysign/screens/items/rapports.dart';
import 'package:easysign/screens/items/admins.dart';
import 'package:easysign/screens/items/parametres.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String? _userRole;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  // Charger le rôle utilisateur
  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('userRole'); // 'admin' | 'superadmin'
      _isLoadingRole = false;
    });
  }

  bool get _isSuperAdmin => _userRole == 'superadmin';

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Écrans dynamiques selon le rôle
  List<Widget> get _screens {
    final screens = <Widget>[Dashboard(onNavigateToTab: _navigateToTab)];

    if (_isSuperAdmin) {
      screens.add(const Horaires());
    }

    screens.add(const Personnel());
    screens.add(const Rapports());

    if (_isSuperAdmin) {
      screens.add(const Admins());
    }

    return screens;
  }

  // BottomNavigationBar dynamique
  List<BottomNavigationBarItem> get _navItems {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Accueil',
      ),
    ];

    if (_isSuperAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Horaires',
        ),
      );
    }

    items.addAll([
      const BottomNavigationBarItem(
        icon: Icon(Icons.group_outlined),
        label: 'Personnel',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.report_outlined),
        label: 'Rapports',
      ),
    ]);

    if (_isSuperAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_add_outlined),
          label: 'Admins',
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EasySign',
          style: TextStyle(
            color: Appcolors.color_2,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.settings_outlined, color: Appcolors.color_2),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Parametres()),
                );
              },
            ),
          ),
        ],
      ),

      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: _navItems,
        selectedItemColor: Appcolors.color_2,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
