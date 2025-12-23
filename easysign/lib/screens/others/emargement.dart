import 'package:easysign/screens/others/scan_qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';
import 'package:easysign/services/presence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Emargement extends StatelessWidget {
  const Emargement({super.key});

  void _showSuccessDialog(BuildContext context, Map data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Émargement validé'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👤 ${data['personnel']}'),
            Text('🕒 ${data['heure']}'),
            Text('📌 ${data['action']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleScan(BuildContext context, String qrCode) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken') ?? '';
    final service = PresenceService(token: token);

    try {
      final response = await service.emarger(qrCode);

      _showSuccessDialog(context, response);
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec titre et heure
            _buildHeader(context),

            const SizedBox(height: 16),

            // Date actuelle
            _buildDateSection(),

            const SizedBox(height: 20),

            // Bouton Scanner biométrie
            _buildScanButton(context),

            const SizedBox(height: 24),

            // Historique du jour
            _buildDailyHistory(),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 20,
        ),
        const Text(
          'Émargement',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Appcolors.color_2.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getCurrentTime(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Appcolors.color_2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.all(12),
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
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getCurrentDate(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final qrCode = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => const ScanQrScreen()),
        );

        if (qrCode != null) {
          _handleScan(context, qrCode);
        }
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Appcolors.color_2,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text('Scanner le code QR'),
        ],
      ),
    );
  }

  Widget _buildDailyHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historique du jour',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _buildHistoryItem(
          type: 'Arrivée',
          time: '08:15',
          icon: Icons.login,
          color: Colors.green,
        ),
        const SizedBox(height: 10),
        _buildHistoryItem(
          type: 'Début pause',
          time: '12:00',
          icon: Icons.coffee,
          color: Colors.orange,
        ),
        const SizedBox(height: 10),
        _buildHistoryItem(
          type: 'Fin pause',
          time: '13:00',
          icon: Icons.coffee_outlined,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required String type,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Enregistré à $time',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
