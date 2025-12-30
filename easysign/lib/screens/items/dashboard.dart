import 'package:easysign/screens/others/emargement.dart';
import 'package:easysign/screens/others/personnel_add.dart';
import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';
import '../../models/rapport.dart';
import '../../services/rapport_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

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

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  Future<void> _loadRapport() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return;

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
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 32),
            _buildStatsCards(),
            // const SizedBox(height: 16),
            // _buildPresenceChart(),
            const SizedBox(height: 32),
            _buildPersonnelStats(),
            const SizedBox(height: 16),
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
    int present = rapport?.totalPresent ?? 0;
    int absent = rapport?.totalAbsents ?? 0;
    int retard = rapport?.totalRetards ?? 0;

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Présences aujourd\'hui',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                backgroundColor: Colors.white,
                alignment: BarChartAlignment.spaceAround,
                maxY: (present + absent + retard).toInt() + 2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Présent');
                          case 1:
                            return const Text('Retard');
                          case 2:
                            return const Text('Absent');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(value.toInt().toString());
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: present.toDouble(),
                        color: Colors.green,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: max(present, absent).toInt() + 2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: retard.toDouble(),
                        color: Colors.orange,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: max(present, absent).toInt() + 2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: absent.toDouble(),
                        color: Colors.red,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: max(present, absent).toInt() + 2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
                    MaterialPageRoute(builder: (context) => const Emargement()),
                  );
                },
                color: Appcolors.color_2,
              ),
              _buildQuickActionButton(
                icon: Icons.person_add_outlined,
                label: 'Ajouter personnel',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PersonnelAdd()),
                  );
                  if (result == true) {
                    _loadRapport();
                  }
                },
                color: Appcolors.color_3,
              ),
              _buildQuickActionButton(
                icon: Icons.group_outlined,
                label: 'Administrateurs',
                onTap: () => widget.onNavigateToTab?.call(4),
                color: Appcolors.color_3,
              ),
              _buildQuickActionButton(
                icon: Icons.calendar_today_outlined,
                label: 'Horaires',
                onTap: () => widget.onNavigateToTab?.call(1),
                color: Appcolors.color_2,
              ),
            ],
          ),
        ],
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
