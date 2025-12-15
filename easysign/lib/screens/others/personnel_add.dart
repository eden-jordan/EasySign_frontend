import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';

class PersonnelAdd extends StatefulWidget {
  const PersonnelAdd({super.key});

  @override
  State<PersonnelAdd> createState() => _PersonnelAddState();
}

class _PersonnelAddState extends State<PersonnelAdd> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _biometrie1Controller = TextEditingController();
  final _biometrie2Controller = TextEditingController();

  bool _isBiometrie1Enregistree = false;
  bool _isBiometrie2Enregistree = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _matriculeController.dispose();
    _biometrie1Controller.dispose();
    _biometrie2Controller.dispose();
    super.dispose();
  }

  void _enregistrerBiometrie(int numero) async {
    setState(() {
      if (numero == 1) {
        _isBiometrie1Enregistree = false;
      } else {
        _isBiometrie2Enregistree = false;
      }
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      if (numero == 1) {
        _isBiometrie1Enregistree = true;
        _biometrie1Controller.text =
            'Empreinte ${_prenomController.text} ${_nomController.text} #1';
      } else {
        _isBiometrie2Enregistree = true;
        _biometrie2Controller.text =
            'Empreinte ${_prenomController.text} ${_nomController.text} #2';
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Empreinte $numero enregistrée avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _enregistrerEmploye() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Employé enregistré avec succès !'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pop(context);
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
          'Nouvel employé',
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer le prénom';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFormField(
                              label: 'Nom',
                              hintText: 'Nom',
                              controller: _nomController,
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer le nom';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _buildFormField(
                        label: 'Email',
                        hintText: 'email@entreprise.fr',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer l\'email';
                          }
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
                        label: 'Téléphone',
                        hintText: '+33 6 12 34 56 78',
                        controller: _telController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 12),

                      _buildFormField(
                        label: 'Matricule',
                        hintText: 'EMP001',
                        controller: _matriculeController,
                        icon: Icons.badge_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le matricule';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enregistrement biométrique',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enregistrez deux empreintes pour plus de sécurité',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.fingerprint,
                                          color: _isBiometrie1Enregistree
                                              ? Colors.green
                                              : Appcolors.color_2,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Empreinte 1',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isBiometrie1Enregistree
                                            ? Colors.green.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.orange.withValues(
                                                alpha: 0.1,
                                              ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        _isBiometrie1Enregistree
                                            ? 'Enregistrée'
                                            : 'À enregistrer',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: _isBiometrie1Enregistree
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isBiometrie1Enregistree)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: TextFormField(
                                      controller: _biometrie1Controller,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        hintText: 'Empreinte enregistrée',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.all(8),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _enregistrerBiometrie(1),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isBiometrie1Enregistree
                                          ? Colors.grey.shade300
                                          : Appcolors.color_2,
                                      foregroundColor: _isBiometrie1Enregistree
                                          ? Colors.grey.shade600
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: Icon(
                                      _isBiometrie1Enregistree
                                          ? Icons.check_circle
                                          : Icons.fingerprint,
                                      size: 16,
                                    ),
                                    label: Text(
                                      _isBiometrie1Enregistree
                                          ? 'Enregistrée'
                                          : 'Enregistrer 1',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.fingerprint,
                                          color: _isBiometrie2Enregistree
                                              ? Colors.green
                                              : Appcolors.color_2,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Empreinte 2',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isBiometrie2Enregistree
                                            ? Colors.green.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.orange.withValues(
                                                alpha: 0.1,
                                              ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        _isBiometrie2Enregistree
                                            ? 'Enregistrée'
                                            : 'À enregistrer',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: _isBiometrie2Enregistree
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isBiometrie2Enregistree)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: TextFormField(
                                      controller: _biometrie2Controller,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        hintText: 'Empreinte enregistrée',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.all(8),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _enregistrerBiometrie(2),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isBiometrie2Enregistree
                                          ? Colors.grey.shade300
                                          : Appcolors.color_2,
                                      foregroundColor: _isBiometrie2Enregistree
                                          ? Colors.grey.shade600
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: Icon(
                                      _isBiometrie2Enregistree
                                          ? Icons.check_circle
                                          : Icons.fingerprint,
                                      size: 16,
                                    ),
                                    label: Text(
                                      _isBiometrie2Enregistree
                                          ? 'Enregistrée'
                                          : 'Enregistrer 2',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _enregistrerEmploye,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolors.color_2,
                      foregroundColor: Colors.white,
                      elevation: 4,
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
                            'Enregistrer l\'employé',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

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
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Les empreintes biométriques sont sécurisées et chiffrées.',
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

                const SizedBox(height: 20),
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
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
