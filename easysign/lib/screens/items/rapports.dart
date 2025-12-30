import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/rapport.dart';
import '../../models/rapportpersonnel.dart';
import '../../services/rapport_service.dart';

class RapportScreen extends StatefulWidget {
  const RapportScreen({super.key});

  @override
  State<RapportScreen> createState() => _RapportScreenState();
}

class _RapportScreenState extends State<RapportScreen> {
  Rapport? rapport;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRapport();
  }

  Future<void> _loadRapport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      if (token == null) throw Exception("Token non trouvé");

      final service = RapportService(token: token);

      final data = await service.journalier(); // Journalier par défaut
      setState(() {
        rapport = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (rapport == null) {
      return const Scaffold(
        body: Center(child: Text('Aucun rapport disponible')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapport'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTotaux(),
          const SizedBox(height: 20),
          const Text(
            'Détails du personnel',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...rapport!.personnels.map(_buildPersonnelCard),
        ],
      ),
    );
  }

  Widget _buildTotaux() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row('Présents', rapport!.totalPresent),
            _row('Absents', rapport!.totalAbsents),
            _row('Retards', rapport!.totalRetards),
            _row('Retards pause', rapport!.totalPauseRetards),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPersonnelCard(Rapportpersonnel p) {
    return Card(
      child: ListTile(
        title: Text(p.nom),
        subtitle: Text(
          'Présent: ${p.present} | Absent: ${p.absent}\n'
          'Retard: ${p.retard} | Pause: ${p.retardPause}',
        ),
      ),
    );
  }

  // ================= PDF =================

  Future<void> _exportPdf() async {
    if (rapport == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Rapport ${rapport!.periode}',
              style: pw.TextStyle(fontSize: 20),
            ),
            pw.SizedBox(height: 10),

            pw.Text('Période : ${rapport!.dateDebut} → ${rapport!.dateFin}'),
            pw.Divider(),

            pw.Text('Totaux', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Présents : ${rapport!.totalPresent}'),
            pw.Text('Absents : ${rapport!.totalAbsents}'),
            pw.Text('Retards : ${rapport!.totalRetards}'),
            pw.Text('Retards pause : ${rapport!.totalPauseRetards}'),

            pw.Divider(),
            pw.Text('Personnel', style: pw.TextStyle(fontSize: 16)),

            ...rapport!.personnels.map(
              (p) => pw.Text(
                '${p.nom} → P:${p.present} A:${p.absent} R:${p.retard} RP:${p.retardPause}',
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
