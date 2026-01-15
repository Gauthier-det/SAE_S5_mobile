import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/providers/auth_provider.dart';

/// Register screen for new user registration
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedGender = 'Autre';

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            birthDate: '',
          );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF1B3D2F),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // Top section with logo placeholder
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                // Form card bubble
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),

                            // Title
                            const Text(
                              'Inscription',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 24),

                            // Error message
                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                            // Nom et Prénom (side by side)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildUnderlineTextField(
                                    controller: _lastNameController,
                                    label: 'Nom *',
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Nom requis';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildUnderlineTextField(
                                    controller: _firstNameController,
                                    label: 'Prénom *',
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Prénom requis';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Email field
                            _buildUnderlineTextField(
                              controller: _emailController,
                              label: 'Email *',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Email requis';
                                }
                                if (!value!.contains('@')) {
                                  return 'Email invalide';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Password field
                            _buildUnderlineTextField(
                              controller: _passwordController,
                              label: 'Mot de passe *',
                              obscureText: true,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Mot de passe requis';
                                }
                                if (value!.length < 8) {
                                  return 'Minimum 8 caractères';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Confirm Password field
                            _buildUnderlineTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirmer le mot de passe *',
                              obscureText: true,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Confirmation requise';
                                }
                                if (value != _passwordController.text) {
                                  return 'Les mots de passe ne correspondent pas';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // Register button
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'S\'INSCRIRE',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Login link
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'se connecter',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildUnderlineTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.black38,
              fontSize: 16,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
