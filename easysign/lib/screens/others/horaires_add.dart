import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easysign/services/organisation_service.dart';
import 'package:easysign/models/horaire.dart';

class HorairesAdd extends StatefulWidget {
  const HorairesAdd({super.key});

  @override
  State<HorairesAdd> createState() => _HorairesAddState();
}

class _HorairesAddState extends State<HorairesAdd> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  TimeOfDay? _arrivalTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? _departureTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay? _breakStartTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay? _breakEndTime = const TimeOfDay(hour: 13, minute: 0);

  // Jours de travail sélectionnés
  final Map<String, bool> _workingDays = {
    'L': true, // Lundi
    'M': true, // Mardi
    'M2': true, // Mercredi
    'J': true, // Jeudi
    'V': true, // Vendredi
    'S': false, // Samedi
    'D': false, // Dimanche
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Méthode pour sélectionner une heure
  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay? initialTime,
    Function(TimeOfDay) onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Appcolors.color_2,
              secondary: Appcolors.color_2,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  // Widget pour un bouton de sélection d'heure
  Widget _buildTimeButton(String label, TimeOfDay? time, Function() onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time == null ? 'Sélectionner' : _formatTime(time),
                  style: TextStyle(
                    fontSize: 14,
                    color: time == null ? Colors.grey.shade500 : Colors.black,
                  ),
                ),
                Icon(Icons.access_time, color: Appcolors.color_2, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Formater l'heure
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Valider et enregistrer l'horaire
  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    if (_arrivalTime == null || _departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les heures'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final arrivalMinutes = _arrivalTime!.hour * 60 + _arrivalTime!.minute;
    final departureMinutes = _departureTime!.hour * 60 + _departureTime!.minute;

    if (departureMinutes <= arrivalMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'L\'heure de départ doit être après l\'heure d\'arrivée',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedDays = _workingDays.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez au moins un jour'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      if (token == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final service = OrganisationService(token: token);

      final horaire = Horaire(
        id: 0,
        organisationId: 0,
        heureArrivee: _formatTime(_arrivalTime!),
        heureDepart: _formatTime(_departureTime!),
        pauseDebut: _formatTime(_breakStartTime!),
        pauseFin: _formatTime(_breakEndTime!),
        joursTravail: selectedDays,
      );

      await service.addHoraire(horaire);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horaire enregistré avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        Navigator.pop(context, true);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nouvel horaire',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte du formulaire
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.05 * 255).round()),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Heure d'arrivée
                      _buildTimeButton(
                        'Heure d\'arrivée',
                        _arrivalTime,
                        () => _selectTime(context, _arrivalTime, (time) {
                          setState(() {
                            _arrivalTime = time;
                          });
                        }),
                      ),

                      const SizedBox(height: 14),

                      // Heure de départ
                      _buildTimeButton(
                        'Heure de départ',
                        _departureTime,
                        () => _selectTime(context, _departureTime, (time) {
                          setState(() {
                            _departureTime = time;
                          });
                        }),
                      ),

                      const SizedBox(height: 14),

                      // Début pause
                      _buildTimeButton(
                        'Début pause',
                        _breakStartTime,
                        () => _selectTime(context, _breakStartTime, (time) {
                          setState(() {
                            _breakStartTime = time;
                          });
                        }),
                      ),

                      const SizedBox(height: 14),

                      // Fin pause
                      _buildTimeButton(
                        'Fin pause',
                        _breakEndTime,
                        () => _selectTime(context, _breakEndTime, (time) {
                          setState(() {
                            _breakEndTime = time;
                          });
                        }),
                      ),

                      const SizedBox(height: 18),

                      // Jours de travail
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jours de travail',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _workingDays.entries.map((entry) {
                                return _buildDayButton(
                                  day: entry.key,
                                  label: entry.key == 'M2' ? 'M' : entry.key,
                                  isSelected: entry.value,
                                  onTap: () {
                                    setState(() {
                                      _workingDays[entry.key] = !entry.value;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'L M M J V S D',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Résumé de l'horaire
                      if (_arrivalTime != null && _departureTime != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Appcolors.color_2.withAlpha(
                              (0.05 * 255).round(),
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Appcolors.color_2.withAlpha(
                                (0.2 * 255).round(),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Appcolors.color_2,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Résumé',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Appcolors.color_2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatTime(_arrivalTime!)} - ${_formatTime(_departureTime!)} '
                                      '(${(_departureTime!.hour * 60 + _departureTime!.minute - _arrivalTime!.hour * 60 - _arrivalTime!.minute) ~/ 60}h)',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton Enregistrer
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveSchedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolors.color_2,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Enregistrer l\'horaire',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Aide/informations
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Les heures sont en format 24h. Assurez-vous que l\'heure de départ est après l\'heure d\'arrivée.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour un bouton de jour
  Widget _buildDayButton({
    required String day,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? Appcolors.color_2 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Appcolors.color_2 : Colors.grey.shade400,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
