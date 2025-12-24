import 'package:easysign/screens/others/emargement.dart';
import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';
import '../../models/rapport.dart';
import '../../services/rapport_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const Dashboard({super.key, this.onNavigateToTab});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Rapport? rapport;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRapport();
  }

  // Récupérer le token d'authentification
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  Future<void> _loadRapport() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        print("Token d'authentification non trouvé.");
        return;
      }

      final service = RapportService(token: token);
      final data = await service.journalier();
      setState(() {
        rapport = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print("Erreur lors du chargement du rapport : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCards(),
            const SizedBox(height: 16),
            _buildPresenceChart(),
            const SizedBox(height: 16),
            _buildPersonnelStats(),
            const SizedBox(height: 16),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  // ================= Cartes de statistiques =================
  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          title: 'Présents',
          value: rapport?.totalPresent.toString() ?? '0',
          color: Colors.green,
          icon: Icons.check_circle_outline,
        ),
        _buildStatCard(
          title: 'Absents',
          value: rapport?.totalAbsents.toString() ?? '0',
          color: Colors.red,
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= Graphique des présences =================
  Widget _buildPresenceChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Présences de la semaine',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Graphique présences',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Simuler un graphique simple
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Graphique des présences',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Légende
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(color: Colors.green, label: 'Présent'),
                _buildLegendItem(color: Colors.orange, label: 'Retard'),
                _buildLegendItem(color: Colors.red, label: 'Absent'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  // ================= Statistiques personnel =================
  Widget _buildPersonnelStats() {
    int totalEmployes =
        (rapport?.totalPresent ?? 0) + (rapport?.totalAbsents ?? 0);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques du personnel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              label: 'Total employés',
              value: totalEmployes.toString(),
              icon: Icons.people_outline,
              color: Colors.blue,
            ),
            const Divider(height: 16),
            _buildStatRow(
              label: 'Total Présents',
              value: (rapport?.totalPresent ?? 0).toString(),
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            const Divider(height: 16),
            _buildStatRow(
              label: 'Total Absents',
              value: (rapport?.totalAbsents ?? 0).toString(),
              icon: Icons.cancel_outlined,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ================= Actions rapides =================
  Widget _buildQuickActions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions rapides',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: [
                _buildQuickActionButton(
                  icon: Icons.qr_code,
                  label: 'Émargement',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Emargement(),
                      ),
                    );
                  },
                  color: Appcolors.color_2,
                ),
                _buildQuickActionButton(
                  icon: Icons.person_add_outlined,
                  label: 'Personnel',
                  onTap: () => widget.onNavigateToTab?.call(2),
                  color: Colors.green,
                ),
                _buildQuickActionButton(
                  icon: Icons.calendar_today_outlined,
                  label: 'Horaires',
                  onTap: () => widget.onNavigateToTab?.call(1),
                  color: Colors.orange,
                ),
                _buildQuickActionButton(
                  icon: Icons.report_outlined,
                  label: 'Rapports',
                  onTap: () => widget.onNavigateToTab?.call(3),
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
