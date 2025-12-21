import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easysign/themes/app_theme.dart';
import 'package:easysign/services/personnel_service.dart';
import 'package:easysign/models/personnel.dart';

class PersonnelEdit extends StatefulWidget {
  final Personnel personnel;

  const PersonnelEdit({super.key, required this.personnel});

  @override
  State<PersonnelEdit> createState() => _PersonnelEditState();
}

class _PersonnelEditState extends State<PersonnelEdit> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nomController = TextEditingController(text: widget.personnel.nom);
    _prenomController = TextEditingController(text: widget.personnel.prenom);
    _emailController = TextEditingController(
      text: widget.personnel.email ?? '',
    );
    _telController = TextEditingController(text: widget.personnel.tel ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  Future<void> _modifierEmploye() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final updatedPersonnel = widget.personnel.copyWith(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        tel: _telController.text.trim().isEmpty
            ? null
            : _telController.text.trim(),
      );

      final service = PersonnelService(token: token);
      await service.update(updatedPersonnel);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employé modifié avec succès'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Modifier l\'employé',
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
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField(
                              label: 'Prénom',
                              hintText: 'Prénom',
                              controller: _prenomController,
                              icon: Icons.person_outline,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Champ requis'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFormField(
                              label: 'Nom',
                              hintText: 'Nom',
                              controller: _nomController,
                              icon: Icons.person_outline,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Champ requis'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildFormField(
                        label: 'Email (optionnel)',
                        hintText: 'email@entreprise.fr',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildFormField(
                        label: 'Téléphone (optionnel)',
                        hintText: '+228 90 00 00 00',
                        controller: _telController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _modifierEmploye,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolors.color_2,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Enregistrer les modifications',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}
