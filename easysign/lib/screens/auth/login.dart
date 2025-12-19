import 'package:easysign/screens/home_screen.dart';
import 'package:easysign/screens/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:easysign/themes/app_theme.dart';
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connexion - EasySign',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Appcolors.color_2, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final token = response['token'];
      final user = response['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userToken', token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Connexion',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'EasySign',
                        style: TextStyle(
                          fontSize: 16,
                          color: Appcolors.color_2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'votre@email.com',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre email';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Email invalide';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mot de passe',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF1976D2),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xFF666666),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre mot de passe';
                                  }
                                  if (value.length < 6) {
                                    return 'Le mot de passe doit contenir au moins 6 caractères';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(
                                  color: Appcolors.color_2,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Appcolors.color_2,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Nouveau sur EasySign ? ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Register(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Créer un compte',
                                  style: TextStyle(
                                    color: Appcolors.color_2,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
