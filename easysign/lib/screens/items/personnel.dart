import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easysign/themes/app_theme.dart';
import 'package:easysign/screens/others/personnel_add.dart';
import 'package:easysign/screens/others/personnel_show.dart';
import 'package:easysign/services/personnel_service.dart';
import 'package:easysign/models/personnel.dart' as model;

class Personnel extends StatefulWidget {
  const Personnel({super.key});

  @override
  State<Personnel> createState() => _PersonnelState();
}

class _PersonnelState extends State<Personnel> {
  final TextEditingController _searchController = TextEditingController();

  List<model.Personnel> _personnels = [];
  List<model.Personnel> _filteredPersonnels = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPersonnel();
    _searchController.addListener(_filterPersonnel);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  Future<void> _loadPersonnel() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token manquant');
      }

      final service = PersonnelService(token: token);
      final data = await service.getAll();

      setState(() {
        _personnels = data;
        _filteredPersonnels = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterPersonnel() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPersonnels = _personnels;
      } else {
        _filteredPersonnels = _personnels.where((p) {
          final fullName = '${p.prenom ?? ''} ${p.nom ?? ''}'.toLowerCase();
          return fullName.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un employé...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Appcolors.color_2,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PersonnelAdd()),
          );
          if (result == true) {
            _loadPersonnel();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (_filteredPersonnels.isEmpty) {
      return const Center(child: Text('Aucun personnel trouvé'));
    }

    return ListView.builder(
      itemCount: _filteredPersonnels.length,
      itemBuilder: (context, index) {
        final personnel = _filteredPersonnels[index];
        return _buildPersonnelCard(personnel);
      },
    );
  }

  Widget _buildPersonnelCard(model.Personnel personnel) {
    final fullName = '${personnel.prenom ?? ''} ${personnel.nom ?? ''}'.trim();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Appcolors.color_2.withOpacity(0.1),
          child: Text(
            fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
            style: TextStyle(color: Appcolors.color_2),
          ),
        ),
        title: Text(
          fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Employé'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PersonnelShow(personnelId: personnel.id),
            ),
          );
        },
      ),
    );
  }
}
