import 'package:easysign/screens/others/scan_qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';
import 'package:easysign/services/presence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/presence.dart';

class Emargement extends StatefulWidget {
  const Emargement({super.key});

  @override
  State<Emargement> createState() => _EmargementState();
}

class _EmargementState extends State<Emargement> {
  List<Presence> _dailyHistory = [];
  bool _loading = true;
  late PresenceService _service;

  @override
  void initState() {
    super.initState();
    _initServiceAndLoadHistory();
  }

  Future<void> _initServiceAndLoadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken') ?? '';
    _service = PresenceService(token: token);

    try {
      final data = await _service.today();
      setState(() {
        _dailyHistory = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError(context, e.toString());
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // =================== DIALOG SUCCESS ===================

  void _showSuccessDialog(BuildContext context, Map data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogcontext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Émargement validé',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _infoRow(Icons.person_outline, data['personnel']),
                const SizedBox(height: 8),
                _infoRow(Icons.schedule, data['heure']),
                const SizedBox(height: 8),
                _infoRow(Icons.flag_outlined, _formatAction(data['action'])),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogcontext).pop();
                      _initServiceAndLoadHistory();
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    );
  }

  String _formatAction(String action) {
    switch (action) {
      case 'arrivee':
        return 'Arrivée';
      case 'pause_debut':
        return 'Début de pause';
      case 'pause_fin':
        return 'Fin de pause';
      case 'depart':
        return 'Départ';
      default:
        return action;
    }
  }

  Future<void> _handleScan(BuildContext context, String qrCode) async {
    try {
      final response = await _service.emarger(qrCode);
      _showSuccessDialog(context, response);
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  // =================== UI ===================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildDateSection(),
            const SizedBox(height: 20),
            Center(child: SizedBox(child: _buildScanButton(context))),
            const SizedBox(height: 24),
            _buildDailyHistory(),
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
          onPressed: () => Navigator.pop(context),
        ),
        const Text(
          'Émargement',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Appcolors.color_2.withOpacity(0.1),
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
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
        if (qrCode != null) _handleScan(context, qrCode);
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

  // =================== HISTORIQUE AVEC NOM & PRÉNOM ===================

  Widget _buildDailyHistory() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_dailyHistory.isEmpty) {
      return const Text("Aucune présence enregistrée aujourd'hui");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historique du jour',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._dailyHistory.map((presence) {
          final personnel = presence.personnel;
          final fullName = '${personnel.prenom} ${personnel.nom}';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (presence.arrivee != null)
                  _buildHistoryItem(
                    type: 'Arrivée',
                    time: presence.arrivee!.substring(11, 16),
                    icon: Icons.login,
                    color: Colors.green,
                  ),
                if (presence.pauseDebut != null)
                  _buildHistoryItem(
                    type: 'Début pause',
                    time: presence.pauseDebut!.substring(11, 16),
                    icon: Icons.coffee,
                    color: Colors.orange,
                  ),
                if (presence.pauseFin != null)
                  _buildHistoryItem(
                    type: 'Fin pause',
                    time: presence.pauseFin!.substring(11, 16),
                    icon: Icons.coffee_outlined,
                    color: Colors.blue,
                  ),
                if (presence.depart != null)
                  _buildHistoryItem(
                    type: 'Départ',
                    time: presence.depart!.substring(11, 16),
                    icon: Icons.logout,
                    color: Colors.red,
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHistoryItem({
    required String type,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text('$type : ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(time),
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
    const days = [
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ];
    const months = [
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
