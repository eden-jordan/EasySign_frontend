import 'package:easysign/screens/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';
import 'package:easysign/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';

class Parametres extends StatefulWidget {
  const Parametres({super.key});

  @override
  State<Parametres> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<Parametres> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _twoFactorEnabled = false;
  bool _isLoading = false;
  bool _userLoading = true; // Ajouté pour gérer le chargement de l'utilisateur

  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _userLoading = true;
    });

    try {
      final user = await AuthService.getAuthenticatedUser();
      setState(() {
        _user = user;
      });
    } catch (e) {
      print("Erreur chargement user: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur chargement user: $e")));
    } finally {
      setState(() {
        _userLoading = false;
      });
    }
  }

  void _logout() async {
    // Affiche d'abord la confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Appcolors.color_2),
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // Si l'utilisateur annule, on quitte
    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken') ?? '';
      if (token.isEmpty) throw Exception("Token introuvable");
      // Appel à ton service de logout
      await AuthService.logout(token);
      await prefs.remove('userToken');

      // Redirection vers l'écran d'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StartScreen()),
      );

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Déconnexion réussie'),
      //     backgroundColor: Colors.green,
      //   ),
      // );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolors.color_2,
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paramètres',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: _userLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey.shade50,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Section Profil
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Avatar avec initiales
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Appcolors.color_2.withOpacity(
                                0.1,
                              ), // Correction: .withOpacity()
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                // Vérification null-safe
                                _user != null &&
                                        _user!.prenom.isNotEmpty &&
                                        _user!.nom.isNotEmpty
                                    ? '${_user!.prenom[0]}${_user!.nom[0]}'
                                    : '?',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Appcolors.color_2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            // Vérification null-safe
                            _user != null
                                ? '${_user!.prenom} ${_user!.nom}'
                                : 'Utilisateur inconnu',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Badge rôle
                          if (_user != null && _user!.role != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _user!.role!.toLowerCase() == 'superadmin'
                                    ? Colors.red.withOpacity(
                                        0.1,
                                      ) // Correction: .withOpacity()
                                    : Colors.blue.withOpacity(
                                        0.1,
                                      ), // Correction: .withOpacity()
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      _user!.role!.toLowerCase() == 'superadmin'
                                      ? Colors.red.withOpacity(
                                          0.3,
                                        ) // Correction: .withOpacity()
                                      : Colors.blue.withOpacity(
                                          0.3,
                                        ), // Correction: .withOpacity()
                                ),
                              ),
                              child: Text(
                                _user!.role!.toLowerCase() == 'superadmin'
                                    ? 'Super Administrateur'
                                    : 'Administrateur',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _user!.role!.toLowerCase() == 'superadmin'
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                // Vérification null-safe
                                _user?.email ?? 'email@non-disponible.com',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Section Préférences
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Préférences',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSettingsItem(
                            icon: Icons.dark_mode_outlined,
                            title: 'Thème sombre',
                            subtitle: 'Activer le mode sombre',
                            trailing: Switch(
                              value: _isDarkMode,
                              onChanged: (value) {
                                setState(() {
                                  _isDarkMode = value;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      value
                                          ? 'Mode sombre activé'
                                          : 'Mode sombre désactivé',
                                    ),
                                  ),
                                );
                              },
                              activeColor: Appcolors
                                  .color_2, // Correction: activeColor au lieu de activeThumbColor
                            ),
                            onTap: () {
                              setState(() {
                                _isDarkMode = !_isDarkMode;
                              });
                            },
                          ),
                          _buildSettingsItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            subtitle: 'Recevoir les alertes',
                            trailing: Switch(
                              value: _notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                              },
                              activeColor: Appcolors.color_2, // Correction
                            ),
                            onTap: () {
                              setState(() {
                                _notificationsEnabled = !_notificationsEnabled;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Section Sécurité
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Sécurité',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSettingsItem(
                            icon: Icons.lock_outline,
                            title: 'Changer le mot de passe',
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Changer le mot de passe'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Section À propos
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'À propos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSettingsItem(
                            icon: Icons.info_outline,
                            title: 'Version',
                            subtitle: '1.0.0',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Appcolors.color_2.withOpacity(
                                  0.1,
                                ), // Correction
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Dernière',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Appcolors.color_2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Version 1.0.0 - Dernière mise à jour',
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildSettingsItem(
                            icon: Icons.description_outlined,
                            title: 'Conditions d\'utilisation',
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Conditions d\'utilisation'),
                                ),
                              );
                            },
                          ),
                          _buildSettingsItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Politique de confidentialité',
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Politique de confidentialité'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bouton de déconnexion
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : OutlinedButton.icon(
                                onPressed: _logout,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.logout, size: 20),
                                label: const Text(
                                  'Se déconnecter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Appcolors.color_2.withOpacity(0.1), // Correction
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Appcolors.color_2, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }
}
