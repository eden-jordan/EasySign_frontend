import 'package:easysign/screens/others/personnel_add.dart';
import 'package:easysign/screens/others/personnel_show.dart';
import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';

class Personnel extends StatefulWidget {
  const Personnel({super.key});

  @override
  State<Personnel> createState() => _PersonnelState();
}

class _PersonnelState extends State<Personnel> {
  final TextEditingController _searchController = TextEditingController();
  List<Employee> employees = [
    Employee(
      name: 'Julie Moreau',
      position: 'Développeuse Frontend',
      status: EmployeeStatus.present,
      statusText: 'Présente',
      avatarColor: Colors.blue,
    ),
    Employee(
      name: 'Thomas Bernard',
      position: 'Chef de projet',
      status: EmployeeStatus.late,
      statusText: 'En retard',
      avatarColor: Colors.orange,
    ),
    Employee(
      name: 'Camille Rousseau',
      position: 'Designer UX/UI',
      status: EmployeeStatus.absent,
      statusText: 'Absente',
      avatarColor: Colors.purple,
    ),
    Employee(
      name: 'Alexandre Petit',
      position: 'Développeur Backend',
      status: EmployeeStatus.present,
      statusText: 'Présent',
      avatarColor: Colors.green,
    ),
    Employee(
      name: 'Émilie Garnier',
      position: 'Responsable Marketing',
      status: EmployeeStatus.onBreak,
      statusText: 'En pause',
      avatarColor: Colors.pink,
    ),
  ];

  List<Employee> filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    filteredEmployees = employees;
    _searchController.addListener(_filterEmployees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredEmployees = employees;
      } else {
        filteredEmployees = employees.where((employee) {
          return employee.name.toLowerCase().contains(query) ||
              employee.position.toLowerCase().contains(query) ||
              employee.statusText.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Color _getStatusColor(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.present:
        return Colors.green;
      case EmployeeStatus.late:
        return Colors.orange;
      case EmployeeStatus.absent:
        return Colors.red;
      case EmployeeStatus.onBreak:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(
                        13,
                      ), // was withOpacity(0.05)
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un employé...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _filterEmployees();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Compteurs de statut
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildStatusCount('Présents', Colors.green, 2),
                  const SizedBox(width: 10),
                  _buildStatusCount('Absents', Colors.red, 1),
                  const SizedBox(width: 10),
                  _buildStatusCount('En retard', Colors.orange, 1),
                  const SizedBox(width: 10),
                  _buildStatusCount('En pause', Colors.blue, 1),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Liste des employés
            Expanded(
              child: filteredEmployees.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 54,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun employé trouvé',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 64),
                      itemCount: filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = filteredEmployees[index];
                        return _buildEmployeeCard(employee);
                      },
                    ),
            ),
          ],
        ),
      ),

      // Bouton flottant pour ajouter
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PersonnelAdd()),
          );
        },
        backgroundColor: Appcolors.color_2,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        child: const Icon(Icons.add, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Widget pour un compteur de statut
  Widget _buildStatusCount(String label, Color color, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(26), // was withOpacity(0.1)
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour une carte d'employé
  Widget _buildEmployeeCard(Employee employee) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // was withOpacity(0.05)
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: employee.avatarColor.withAlpha(26), // was withOpacity(0.1)
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              employee.name.split(' ').map((n) => n[0]).join(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: employee.avatarColor,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employé',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              employee.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            employee.position,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(
              employee.status,
            ).withAlpha(26), // was withOpacity(0.1)
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getStatusColor(
                employee.status,
              ).withAlpha(76), // was withOpacity(0.3)
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(employee.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                employee.statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(employee.status),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PersonnelShow()),
          );
        },
      ),
    );
  }
}

// Enum pour les statuts des employés
enum EmployeeStatus { present, late, absent, onBreak }

// Classe modèle pour un employé
class Employee {
  final String name;
  final String position;
  final EmployeeStatus status;
  final String statusText;
  final Color avatarColor;

  Employee({
    required this.name,
    required this.position,
    required this.status,
    required this.statusText,
    required this.avatarColor,
  });
}
