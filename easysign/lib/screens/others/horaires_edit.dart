import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easysign/services/organisation_service.dart';
import 'package:easysign/models/horaire.dart';

class HorairesEdit extends StatefulWidget {
  final Horaire horaire;

  const HorairesEdit({super.key, required this.horaire});

  @override
  State<HorairesEdit> createState() => _HorairesEditState();
}

class _HorairesEditState extends State<HorairesEdit> {
  final _formKey = GlobalKey<FormState>();

  late TimeOfDay _arrivalTime;
  late TimeOfDay _departureTime;
  late TimeOfDay _breakStartTime;
  late TimeOfDay _breakEndTime;

  late Map<String, bool> _workingDays;

  @override
  void initState() {
    super.initState();

    _arrivalTime = _parseTime(widget.horaire.heureArrivee);
    _departureTime = _parseTime(widget.horaire.heureDepart);
    _breakStartTime = _parseTime(widget.horaire.pauseDebut);
    _breakEndTime = _parseTime(widget.horaire.pauseFin);

    _workingDays = {
      'L': widget.horaire.joursTravail.contains('L'),
      'M': widget.horaire.joursTravail.contains('M'),
      'Me': widget.horaire.joursTravail.contains('Me'),
      'J': widget.horaire.joursTravail.contains('J'),
      'V': widget.horaire.joursTravail.contains('V'),
      'S': widget.horaire.joursTravail.contains('S'),
      'D': widget.horaire.joursTravail.contains('D'),
    };
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay initialTime,
    Function(TimeOfDay) onSelected,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _updateSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedDays = _workingDays.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez au moins un jour')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      if (token == null) throw Exception('Utilisateur non authentifié');

      final service = OrganisationService(token: token);

      final updatedHoraire = Horaire(
        id: widget.horaire.id,
        organisationId: widget.horaire.organisationId,
        heureArrivee: _formatTime(_arrivalTime),
        heureDepart: _formatTime(_departureTime),
        pauseDebut: _formatTime(_breakStartTime),
        pauseFin: _formatTime(_breakEndTime),
        joursTravail: selectedDays,
      );

      await service.updateHoraire(updatedHoraire);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horaire modifié avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.pop(context, true);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier l’horaire',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _timeButton(
                'Arrivée',
                _arrivalTime,
                () => _selectTime(
                  context,
                  _arrivalTime,
                  (t) => setState(() => _arrivalTime = t),
                ),
              ),
              const SizedBox(height: 12),
              _timeButton(
                'Départ',
                _departureTime,
                () => _selectTime(
                  context,
                  _departureTime,
                  (t) => setState(() => _departureTime = t),
                ),
              ),
              const SizedBox(height: 12),
              _timeButton(
                'Pause début',
                _breakStartTime,
                () => _selectTime(
                  context,
                  _breakStartTime,
                  (t) => setState(() => _breakStartTime = t),
                ),
              ),
              const SizedBox(height: 12),
              _timeButton(
                'Pause fin',
                _breakEndTime,
                () => _selectTime(
                  context,
                  _breakEndTime,
                  (t) => setState(() => _breakEndTime = t),
                ),
              ),
              const SizedBox(height: 20),

              Wrap(
                spacing: 8,
                children: _workingDays.keys.map((day) {
                  return ChoiceChip(
                    label: Text(day),
                    selected: _workingDays[day]!,
                    selectedColor: Appcolors.color_2,
                    onSelected: (v) {
                      setState(() => _workingDays[day] = v);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _updateSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Appcolors.color_2,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Modifier l’horaire'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeButton(String label, TimeOfDay time, VoidCallback onTap) {
    return ListTile(
      title: Text(label),
      trailing: Text(_formatTime(time)),
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
