import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';

class Emargement extends StatelessWidget {
  const Emargement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec titre et heure
            _buildHeader(context),

            const SizedBox(height: 24),

            // Date actuelle
            _buildDateSection(),

            const SizedBox(height: 32),

            // Bouton Scanner biométrie
            _buildScanButton(),

            const SizedBox(height: 40),

            // Historique du jour
            _buildDailyHistory(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // En-tête avec titre et heure
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Center(
          child: const Text(
            'Émargement',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Appcolors.color_2.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getCurrentTime(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Appcolors.color_2,
            ),
          ),
        ),
      ],
    );
  }

  // Section date actuelle
  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: Appcolors.color_2,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            _getCurrentDate(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Bouton Scanner biométrie
  Widget _buildScanButton() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Appcolors.color_2,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Appcolors.color_2.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.fingerprint, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scanner biométrie',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Placez votre doigt sur le scanner',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Historique du jour
  Widget _buildDailyHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historique du jour',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),

        // Arrivée
        _buildHistoryItem(
          type: 'Arrivée',
          time: '08:15',
          icon: Icons.login,
          color: Colors.green,
        ),

        const SizedBox(height: 16),

        // Début pause
        _buildHistoryItem(
          type: 'Début pause',
          time: '12:00',
          icon: Icons.coffee,
          color: Colors.orange,
        ),

        const SizedBox(height: 16),

        // Fin pause
        _buildHistoryItem(
          type: 'Fin pause',
          time: '13:00',
          icon: Icons.coffee_outlined,
          color: Colors.blue,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // Item d'historique
  Widget _buildHistoryItem({
    required String type,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enregistré à $time',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthodes utilitaires pour obtenir l'heure et la date
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final days = [
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ];
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
