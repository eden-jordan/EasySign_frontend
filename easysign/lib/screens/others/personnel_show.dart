import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';

class PersonnelShow extends StatelessWidget {
  const PersonnelShow({super.key});

  @override
  Widget build(BuildContext context) {
    // Données par défaut pour le visuel
    final employeeData = {
      'name': 'Julie Moreau',
      'position': 'Développeuse Frontend',
      'statusText': 'Présente',
      'arrivalTime': '08:15',
      'email': 'julie.moreau@entreprise.fr',
      'phone': '+33 6 12 34 56 78',
      'employeeId': 'EMP001',
      'hireDate': '15/03/2023',
    };

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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Modifier l\'employé')),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // En-tête avec infos principales
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Avatar et nom
                    Column(
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
                              _getInitials(employeeData['name']!),
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
                          employeeData['name']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          employeeData['position']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _applyOpacity(
                          _getStatusColor(employeeData['statusText']!),
                          0.10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _applyOpacity(
                            _getStatusColor(employeeData['statusText']!),
                            0.30,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                employeeData['statusText']!,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${employeeData['statusText']} depuis ${employeeData['arrivalTime']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(
                                employeeData['statusText']!,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: employeeData['email']!,
                    ),
                    const SizedBox(height: 12),

                    // Téléphone
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Téléphone',
                      value: employeeData['phone']!,
                    ),
                    const SizedBox(height: 12),

                    // Matricule
                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Matricule',
                      value: employeeData['employeeId']!,
                    ),
                    const SizedBox(height: 12),

                    // Date d'embauche
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date d\'embauche',
                      value: employeeData['hireDate']!,
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
                              content: Text('Enregistrement biométrique'),
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
                        icon: const Icon(Icons.fingerprint, size: 20),
                        label: const Text(
                          'Enregistrer biométrie',
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

              // Historique récent
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
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Arrivée
                    _buildHistoryItem(
                      icon: Icons.login,
                      label: 'Arrivée',
                      time: 'Aujourd\'hui, ${employeeData['arrivalTime']}',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),

                    // Départ
                    _buildHistoryItem(
                      icon: Icons.logout,
                      label: 'Départ',
                      time: 'Hier, 17:30',
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),

                    // Fin pause
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

              // Informations supplémentaires
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      label: 'Heures/semaine',
                      value: '35h',
                      icon: Icons.access_time,
                      color: Colors.blue,
                    ),
                    _buildStatItem(
                      label: 'Jours présents',
                      value: '18/20',
                      icon: Icons.event_available,
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      label: 'Congés restants',
                      value: '22j',
                      icon: Icons.beach_access,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour obtenir les initiales
  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name.substring(0, 2).toUpperCase();
  }

  // Helper pour appliquer l'opacité sans withOpacity déprécié
  Color _applyOpacity(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }

  // Widget pour une ligne d'information
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
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour un élément d'historique
  Widget _buildHistoryItem({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }

  // Widget pour un élément de statistique
  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _applyOpacity(color, 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Obtenir la couleur du statut
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Présent':
      case 'Présente':
        return Colors.green;
      case 'En retard':
        return Colors.orange;
      case 'Absent':
      case 'Absente':
        return Colors.red;
      case 'En pause':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
