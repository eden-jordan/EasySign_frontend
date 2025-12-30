import 'package:flutter/material.dart';

class RapportScreen extends StatelessWidget {
  const RapportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Bientôt disponible !')));
  }
}
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:printing/printing.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:intl/intl.dart';

// import '../../models/rapport.dart';
// import '../../models/rapportpersonnel.dart';
// import '../../services/rapport_service.dart';

// enum RapportType { journalier, mensuel, annuel }

// class RapportScreen extends StatefulWidget {
//   const RapportScreen({super.key});

//   @override
//   State<RapportScreen> createState() => _RapportScreenState();
// }

// class _RapportScreenState extends State<RapportScreen> {
//   Rapport? rapport;
//   bool loading = true;
//   RapportType type = RapportType.journalier;

//   DateTime? selectedDate; // Pour journalier
//   int? selectedMonth; // Pour mensuel
//   int? selectedYear; // Pour mensuel ou annuel

//   @override
//   void initState() {
//     super.initState();
//     selectedDate = DateTime.now();
//     selectedMonth = DateTime.now().month;
//     selectedYear = DateTime.now().year;
//     _loadRapport();
//   }

//   Future<void> _loadRapport() async {
//     setState(() => loading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('userToken');
//       if (token == null) throw Exception("Token non trouvé");

//       final service = RapportService(token: token);

//       Rapport data;
//       if (type == RapportType.journalier) {
//         data = await service.journalier(
//           date: DateFormat('yyyy-MM-dd').format(selectedDate!),
//         );
//       } else if (type == RapportType.mensuel) {
//         data = await service.mensuel(
//           month: selectedMonth!,
//           year: selectedYear!,
//         );
//       } else {
//         data = await service.annuel(year: selectedYear!);
//       }

//       setState(() {
//         rapport = data;
//         loading = false;
//       });
//     } catch (e) {
//       setState(() => loading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
//     }
//   }

//   Future<void> _pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: selectedDate!,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (date != null) {
//       setState(() => selectedDate = date);
//       _loadRapport();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Rapport'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.picture_as_pdf),
//             onPressed: _exportPdf,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildFilters(),
//           Expanded(
//             child: loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : rapport == null
//                 ? const Center(child: Text('Aucun rapport disponible'))
//                 : ListView(
//                     padding: const EdgeInsets.all(16),
//                     children: [
//                       _buildTotaux(),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'Détails du personnel',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       ...rapport!.personnels.map(_buildPersonnelCard),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilters() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           DropdownButton<RapportType>(
//             value: type,
//             items: RapportType.values
//                 .map(
//                   (e) => DropdownMenuItem(
//                     value: e,
//                     child: Text(e.name[0].toUpperCase() + e.name.substring(1)),
//                   ),
//                 )
//                 .toList(),
//             onChanged: (val) {
//               if (val != null) {
//                 setState(() => type = val);
//                 _loadRapport();
//               }
//             },
//           ),
//           const SizedBox(width: 10),
//           if (type == RapportType.journalier)
//             ElevatedButton(
//               onPressed: _pickDate,
//               child: Text(DateFormat('yyyy-MM-dd').format(selectedDate!)),
//             )
//           else if (type == RapportType.mensuel)
//             Row(
//               children: [
//                 DropdownButton<int>(
//                   value: selectedMonth,
//                   items: List.generate(12, (i) => i + 1)
//                       .map(
//                         (m) => DropdownMenuItem(
//                           value: m,
//                           child: Text(m.toString()),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: (val) {
//                     if (val != null) {
//                       setState(() => selectedMonth = val);
//                       _loadRapport();
//                     }
//                   },
//                 ),
//                 const SizedBox(width: 5),
//                 DropdownButton<int>(
//                   value: selectedYear,
//                   items: List.generate(5, (i) => DateTime.now().year - i)
//                       .map(
//                         (y) => DropdownMenuItem(
//                           value: y,
//                           child: Text(y.toString()),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: (val) {
//                     if (val != null) {
//                       setState(() => selectedYear = val);
//                       _loadRapport();
//                     }
//                   },
//                 ),
//               ],
//             )
//           else // annuel
//             DropdownButton<int>(
//               value: selectedYear,
//               items: List.generate(5, (i) => DateTime.now().year - i)
//                   .map(
//                     (y) =>
//                         DropdownMenuItem(value: y, child: Text(y.toString())),
//                   )
//                   .toList(),
//               onChanged: (val) {
//                 if (val != null) {
//                   setState(() => selectedYear = val);
//                   _loadRapport();
//                 }
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTotaux() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _row('Présents', rapport!.totalPresent),
//             _row('Absents', rapport!.totalAbsents),
//             _row('Retards', rapport!.totalRetards),
//             _row('Retards pause', rapport!.totalPauseRetards),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _row(String label, int value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label),
//         Text(
//           value.toString(),
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }

//   Widget _buildPersonnelCard(Rapportpersonnel p) {
//     return Card(
//       child: ListTile(
//         title: Text(p.nom),
//         subtitle: Text(
//           'Présent: ${p.present} | Absent: ${p.absent}\nRetard: ${p.retard} | Pause: ${p.retardPause}',
//         ),
//       ),
//     );
//   }

//   Future<void> _exportPdf() async {
//     if (rapport == null) return;

//     final pdf = pw.Document();
//     pdf.addPage(
//       pw.Page(
//         build: (context) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text(
//               'Rapport ${rapport!.periode}',
//               style: pw.TextStyle(fontSize: 20),
//             ),
//             pw.SizedBox(height: 10),
//             pw.Text('Période : ${rapport!.dateDebut} → ${rapport!.dateFin}'),
//             pw.Divider(),
//             pw.Text('Totaux', style: pw.TextStyle(fontSize: 16)),
//             pw.Text('Présents : ${rapport!.totalPresent}'),
//             pw.Text('Absents : ${rapport!.totalAbsents}'),
//             pw.Text('Retards : ${rapport!.totalRetards}'),
//             pw.Text('Retards pause : ${rapport!.totalPauseRetards}'),
//             pw.Divider(),
//             pw.Text('Personnel', style: pw.TextStyle(fontSize: 16)),
//             ...rapport!.personnels.map(
//               (p) => pw.Text(
//                 '${p.nom} → P:${p.present} A:${p.absent} R:${p.retard} RP:${p.retardPause}',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//     await Printing.layoutPdf(onLayout: (format) => pdf.save());
//   }
// }
