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
    screens.add(const RapportScreen());

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
          'EASYSIGN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24, // Légèrement augmenté pour plus d'impact
            fontWeight: FontWeight.w700, // Plus gras pour mieux se démarquer
            letterSpacing: 1.5, // Espacement amélioré pour l'élégance
          ),
        ),
        centerTitle: true,
        backgroundColor: Appcolors.color_2,
        elevation: 3, // Ombre subtile pour la profondeur
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15), // Bords arrondis subtils en bas
          ),
        ),
        actions: [
          // Container avec effet de profondeur
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Parametres()),
                  );
                },
                splashColor: Colors.white.withOpacity(
                  0.2,
                ), // Effet de splash personnalisé
                highlightColor: Colors.white.withOpacity(
                  0.1,
                ), // Effet de highlight
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
        // Dégradé subtil sur la couleur existante
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Appcolors.color_2, Appcolors.color_2.withOpacity(0.95)],
              stops: [0.0, 1.0],
            ),
          ),
        ),
        // Hauteur légèrement augmentée
        toolbarHeight: 70,
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
