import 'package:easysign/screens/others/personnel_edit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easysign/themes/app_theme.dart';
import 'package:easysign/services/personnel_service.dart';
import 'package:easysign/models/personnel.dart';

class PersonnelShow extends StatefulWidget {
  final int personnelId;

  const PersonnelShow({super.key, required this.personnelId});

  @override
  State<PersonnelShow> createState() => _PersonnelShowState();
}

class _PersonnelShowState extends State<PersonnelShow> {
  late Future<Personnel> _personnelFuture;

  @override
  void initState() {
    super.initState();
    _personnelFuture = _loadPersonnel();
  }

  Future<Personnel> _loadPersonnel() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token == null) {
      throw Exception('Utilisateur non authentifié');
    }

    final service = PersonnelService(token: token);
    return service.getById(widget.personnelId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Personnel>(
      future: _personnelFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                snapshot.error.toString().replaceAll('Exception: ', ''),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final personnel = snapshot.data!;
        final fullName = '${personnel.prenom} ${personnel.nom}';

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Fiche employé',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () async {
                  final bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PersonnelEdit(personnel: personnel),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      _personnelFuture = _loadPersonnel();
                    });
                  }
                },
              ),
            ],
          ),
          body: _buildPersonnelDetails(personnel),
        );
      },
    );
  }

  Widget _buildPersonnelDetails(Personnel personnel) {
    final fullName = '${personnel.prenom} ${personnel.nom}';

    return Container(
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _applyOpacity(Appcolors.color_2, 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(fullName),
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
                    fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Employé',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Informations personnelles
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Appcolors.color_2,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Informations personnelles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: personnel.email ?? 'Non renseigné',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Téléphone',
                    value: personnel.tel ?? 'Non renseigné',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Boutons d'action
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Exporter le badge PDF'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Appcolors.color_2,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.badge, size: 20),
                      label: const Text(
                        'Exporter badge PDF',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Historique complet')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Appcolors.color_2,
                        side: BorderSide(color: Appcolors.color_2, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.history, size: 20),
                      label: const Text(
                        'Voir l\'historique complet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Historique simulé
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history_toggle_off_outlined,
                        color: Appcolors.color_2,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Historique récent',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildHistoryItem(
                    icon: Icons.login,
                    label: 'Arrivée',
                    time: 'Aujourd\'hui, 08:15',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildHistoryItem(
                    icon: Icons.logout,
                    label: 'Départ',
                    time: 'Hier, 17:30',
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _buildHistoryItem(
                    icon: Icons.free_breakfast_outlined,
                    label: 'Fin pause',
                    time: 'Hier, 13:15',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  Color _applyOpacity(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _applyOpacity(color, 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
