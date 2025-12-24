import 'package:easysign/models/action_emargement.dart';
import 'package:easysign/models/presence.dart';
import 'package:easysign/screens/others/personnel_edit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easysign/themes/app_theme.dart';
import 'package:easysign/services/personnel_service.dart';
import 'package:easysign/models/personnel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:easysign/services/presence_service.dart';
import 'package:intl/intl.dart';

class PersonnelShow extends StatefulWidget {
  final int personnelId;

  const PersonnelShow({super.key, required this.personnelId});

  @override
  State<PersonnelShow> createState() => _PersonnelShowState();
}

class _PersonnelShowState extends State<PersonnelShow> {
  late Future<Personnel> _personnelFuture;
  late Future<List<ActionEmargement>> _historyFuture;

  IconData getIcon(String statut) {
    switch (statut) {
      case 'Present':
        return Icons.login; // arrivée
      case 'En_pause':
        return Icons.free_breakfast_outlined; // pause
      case 'Termine':
        return Icons.logout; // départ
      default:
        return Icons.help_outline;
    }
  }

  Color getColor(String statut) {
    switch (statut) {
      case 'Present':
        return Colors.green;
      case 'En_pause':
        return Colors.orange;
      case 'Termine':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _personnelFuture = _loadPersonnel();
    _historyFuture = _loadHistory();
  }

  Future<List<ActionEmargement>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    if (token == null) throw Exception('Utilisateur non authentifié');

    final service = PresenceService(token: token);

    // Nouvelle méthode pour récupérer toutes les actions du jour
    final actions = await service.history(widget.personnelId);

    return actions;
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

  Future<void> _exportBadgePdf(Personnel personnel) async {
    final pdf = pw.Document();

    final fullName = '${personnel.prenom} ${personnel.nom}';
    final initials = _getInitials(fullName);
    final qrData = personnel.qrCode?.isNotEmpty == true
        ? personnel.qrCode!
        : '';

    // Couleurs
    final primaryColor = PdfColor.fromInt(0xFF1a237e);
    final secondaryColor = PdfColor.fromInt(0xFF0d47a1);
    final accentColor = PdfColor.fromInt(0xFFe3f2fd);
    final textColor = PdfColor.fromInt(0xFF212121);
    final subtitleColor = PdfColor.fromInt(0xFF757575);
    final lightGray = PdfColor.fromInt(0xFFF5F5F5);
    final white = PdfColors.white;

    String formatDate(DateTime date) {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month/$year';
    }

    final currentDate = formatDate(DateTime.now());

    // ---------------- Page 1 : Recto ----------------
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          150 * PdfPageFormat.mm,
          100 * PdfPageFormat.mm,
        ),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: white,
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(
                color: PdfColor.fromInt(0xFFE0E0E0),
                width: 0.5,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Bande supérieure
                pw.Container(
                  height: 24,
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: pw.Alignment.topLeft,
                      end: pw.Alignment.bottomRight,
                    ),
                    borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(12),
                      topRight: pw.Radius.circular(12),
                    ),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'BADGE PROFESSIONNEL',
                      style: pw.TextStyle(
                        color: white,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                pw.Padding(
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Initiales / Photo
                      pw.Container(
                        width: 60,
                        height: 60,
                        margin: const pw.EdgeInsets.only(right: 16),
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          gradient: pw.LinearGradient(
                            colors: [secondaryColor, primaryColor],
                            begin: pw.Alignment.topLeft,
                            end: pw.Alignment.bottomRight,
                          ),
                          boxShadow: [
                            pw.BoxShadow(
                              color: PdfColor.fromInt(0x33000000),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            initials,
                            style: pw.TextStyle(
                              color: white,
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Infos principales
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              fullName,
                              style: pw.TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Container(
                              decoration: pw.BoxDecoration(
                                color: accentColor,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: pw.Text(
                                'EMPLOYÉ',
                                style: pw.TextStyle(
                                  color: primaryColor,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 12),

                            // Email
                            pw.Row(
                              children: [
                                pw.Container(
                                  width: 20,
                                  height: 20,
                                  margin: const pw.EdgeInsets.only(right: 6),
                                  decoration: pw.BoxDecoration(
                                    color: lightGray,
                                    borderRadius: pw.BorderRadius.circular(4),
                                  ),
                                  child: pw.Center(
                                    child: pw.Text(
                                      '@',
                                      style: pw.TextStyle(
                                        color: primaryColor,
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  child: pw.Text(
                                    personnel.email ?? 'Non renseigné',
                                    style: pw.TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 6),

                            // Téléphone
                            pw.Row(
                              children: [
                                pw.Container(
                                  width: 20,
                                  height: 20,
                                  margin: const pw.EdgeInsets.only(right: 6),
                                  decoration: pw.BoxDecoration(
                                    color: lightGray,
                                    borderRadius: pw.BorderRadius.circular(4),
                                  ),
                                  child: pw.Center(
                                    child: pw.Text(
                                      'Tel',
                                      style: pw.TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  child: pw.Text(
                                    personnel.tel ?? 'Non renseigné',
                                    style: pw.TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Pied de page
                pw.Spacer(),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: lightGray,
                    borderRadius: const pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(12),
                      bottomRight: pw.Radius.circular(12),
                    ),
                  ),
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // ---------------- Page 2 : Verso ----------------
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          150 * PdfPageFormat.mm,
          100 * PdfPageFormat.mm,
        ),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: white,
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(
                color: PdfColor.fromInt(0xFFE0E0E0),
                width: 0.5,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  height: 24,
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [secondaryColor, primaryColor],
                      begin: pw.Alignment.topLeft,
                      end: pw.Alignment.bottomRight,
                    ),
                    borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(12),
                      topRight: pw.Radius.circular(12),
                    ),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'IDENTIFICATION NUMÉRIQUE',
                      style: pw.TextStyle(
                        color: white,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),

                // QR code
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(
                    errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high,
                  ),
                  data: qrData,
                  width: 120,
                  height: 120,
                  drawText: false,
                  color: primaryColor,
                ),

                pw.SizedBox(height: 12),
                pw.Text(
                  'SCANNER POUR VÉRIFICATION',
                  style: pw.TextStyle(
                    color: primaryColor,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),

                pw.Spacer(),

                // Instructions
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: accentColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: const pw.EdgeInsets.all(12),
                  margin: const pw.EdgeInsets.symmetric(horizontal: 16),
                  child: pw.Text(
                    'INSTRUCTIONS :\n'
                    ' Présentez ce badge à l\'entrée\n'
                    ' Badge personnel et non transférable\n'
                    ' Conserver en bon état',
                    style: pw.TextStyle(
                      color: textColor,
                      fontSize: 8,
                      height: 1.3,
                    ),
                  ),
                ),

                pw.SizedBox(height: 12),

                // Pied de page verso
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: lightGray,
                    borderRadius: const pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(12),
                      bottomRight: pw.Radius.circular(12),
                    ),
                  ),
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'ÉMIS LE: $currentDate',
                        style: pw.TextStyle(color: subtitleColor, fontSize: 8),
                      ),
                      pw.Text(
                        initials,
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Impression ou export
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
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
                      onPressed: () => _exportBadgePdf(personnel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Appcolors.color_2,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.badge, size: 18),
                      label: const Text(
                        'Exporter badge PDF',
                        style: TextStyle(
                          fontSize: 12,
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
                        side: BorderSide(color: Appcolors.color_2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text(
                        'Voir l\'historique',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

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
                  FutureBuilder<List<ActionEmargement>>(
                    future: _historyFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'Erreur: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      }
                      final history = snapshot.data!;
                      if (history.isEmpty) {
                        return const Text('Aucune présence enregistrée.');
                      }

                      return Column(
                        children: history.map((a) {
                          DateTime parsedDate = DateTime.parse(a.timestamp);
                          final time = DateFormat('HH:mm').format(parsedDate);

                          IconData icon;
                          Color color;

                          switch (a.typeAction) {
                            case 'arrivee':
                              icon = Icons.login;
                              color = Colors.green;
                              break;
                            case 'pause_debut':
                              icon = Icons.free_breakfast_outlined;
                              color = Colors.orange;
                              break;
                            case 'pause_fin':
                              icon = Icons.login;
                              color = Colors.green;
                              break;
                            case 'depart':
                              icon = Icons.logout;
                              color = Colors.red;
                              break;
                            default:
                              icon = Icons.help_outline;
                              color = Colors.grey;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildHistoryItem(
                              icon: icon,
                              label: a.typeAction.capitalize(),
                              time: time,
                              color: color,
                            ),
                          );
                        }).toList(),
                      );
                    },
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

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
