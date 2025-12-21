import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';
import 'package:easysign/screens/others/admin_add.dart';
import 'package:easysign/models/user.dart';
import 'package:easysign/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Admins extends StatefulWidget {
  const Admins({super.key});

  @override
  State<Admins> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<Admins> {
  final TextEditingController _searchController = TextEditingController();

  List<User> _admins = [];
  List<User> _filteredAdmins = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
    _searchController.addListener(_filterAdmins);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Récupérer le token d'authentification
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  // Charger les administrateurs depuis l'API
  Future<void> _loadAdmins() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Récupérer le token
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }
      _authToken = token;

      // Appeler l'API
      final admins = await UserService.fetchAdmins(token);

      setState(() {
        _admins = admins;
        _filteredAdmins = admins;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Filtrer les admins selon la recherche
  void _filterAdmins() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredAdmins = _admins;
      } else {
        _filteredAdmins = _admins.where((admin) {
          final fullName = '${admin.prenom} ${admin.nom}'.toLowerCase();
          return fullName.contains(query) ||
              admin.email.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // Rafraîchir la liste
  Future<void> _refreshAdmins() async {
    await _loadAdmins();
    setState(() {});
  }

  // Obtenir le texte du rôle formaté
  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return 'Super Administrateur';
      case 'admin':
        return 'Administrateur';
      default:
        return role;
    }
  }

  // Obtenir la couleur du rôle
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return Colors.red;
      case 'admin':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Obtenir les initiales d'un admin
  String _getInitials(String prenom, String nom) {
    if (prenom.isNotEmpty && nom.isNotEmpty) {
      return '${prenom[0]}${nom[0]}'.toUpperCase();
    }
    if (prenom.isNotEmpty) {
      return prenom.substring(0, 2).toUpperCase();
    }
    if (nom.isNotEmpty) {
      return nom.substring(0, 2).toUpperCase();
    }
    return '??';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un administrateur...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _filterAdmins();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Compteurs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _filteredAdmins.length.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Administrateurs',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Contenu principal
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshAdmins,
                color: Appcolors.color_2,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),

      // Bouton flottant pour ajouter
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminAdd()),
          );
          if (added == true) {
            await _refreshAdmins();
          }
        },
        backgroundColor: Appcolors.color_2,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: const Icon(Icons.add, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Widget pour le contenu principal
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Appcolors.color_2),
      );
    }

    if (_errorMessage.isNotEmpty && _admins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshAdmins,
              style: ElevatedButton.styleFrom(
                backgroundColor: Appcolors.color_2,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_filteredAdmins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Aucun administrateur'
                  : 'Aucun résultat',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Ajoutez un premier administrateur'
                  : 'Essayez avec d\'autres termes',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 60),
      itemCount: _filteredAdmins.length,
      itemBuilder: (context, index) {
        final admin = _filteredAdmins[index];
        return _buildAdminCard(admin);
      },
    );
  }

  // Widget pour une carte d'administrateur
  Widget _buildAdminCard(User admin) {
    final roleText = _getRoleText(admin.role);
    final roleColor = _getRoleColor(admin.role);
    final initials = _getInitials(admin.prenom, admin.nom);
    final fullName = '${admin.prenom} ${admin.nom}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Appcolors.color_2.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Appcolors.color_2,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              fullName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            admin.email,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: roleColor.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: roleColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                roleText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: roleColor,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Détails de $fullName'),
              backgroundColor: Appcolors.color_2,
            ),
          );
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Actions'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Modifier'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Modifier $fullName')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Supprimer'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Supprimer $fullName')),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
