import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';
import 'package:easysign/screens/others/horaires_add.dart';
import 'package:easysign/services/organisation_service.dart';
import 'package:easysign/models/horaire.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Horaires extends StatefulWidget {
  const Horaires({super.key});

  @override
  State<Horaires> createState() => _HorairesState();
}

class _HorairesState extends State<Horaires> {
  late Future<List<Horaire>> _horairesFuture;

  @override
  void initState() {
    super.initState();
    _horairesFuture = _loadHoraires();
  }

  Future<List<Horaire>> _loadHoraires() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken') ?? '';

    final service = OrganisationService(token: token);
    return service.getHoraires();
  }

  String _formatJours(List<String> jours) {
    return jours.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.shade50,
        child: FutureBuilder<List<Horaire>>(
          future: _horairesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final horaires = snapshot.data ?? [];
            final bool hasHoraire = horaires.isNotEmpty;
            final Horaire? horaire = hasHoraire ? horaires.first : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  if (hasHoraire && horaire != null)
                    _buildScheduleCard(
                      title: 'Horaire de l’organisation',
                      arrival: horaire.heureArrivee,
                      departure: horaire.heureDepart,
                      breakStart: horaire.pauseDebut,
                      breakEnd: horaire.pauseFin,
                      days: _formatJours(horaire.joursTravail),
                      icon: Icons.access_time,
                      color: Appcolors.color_2,
                    ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (!hasHoraire)
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HorairesAdd(),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    _horairesFuture = _loadHoraires();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Appcolors.color_2,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text(
                                'Ajouter un horaire',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                        if (hasHoraire)
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HorairesAdd(),
                                  ),
                                );
                                setState(() {
                                  _horairesFuture = _loadHoraires();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Appcolors.color_2,
                                side: BorderSide(
                                  color: Appcolors.color_2,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text(
                                'Modifier l’horaire',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Informations',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Les horaires définis ici sont utilisés pour la gestion des présences et le calcul des heures de travail.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.4,
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
      ),
    );
  }

  Widget _buildScheduleCard({
    required String title,
    required String arrival,
    required String departure,
    required String breakStart,
    required String breakEnd,
    required String days,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _row('Arrivée', arrival, Icons.login, Colors.green),
            _row('Départ', departure, Icons.logout, Colors.red),
            const SizedBox(height: 10),
            Text('Pause : $breakStart - $breakEnd'),
            const SizedBox(height: 6),
            Text('Jours : $days'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text('$label : $value'),
        ],
      ),
    );
  }
}
