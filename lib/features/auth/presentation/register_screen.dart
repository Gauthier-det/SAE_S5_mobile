import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/providers/auth_provider.dart';

/// User registration screen.
///
/// A stateful widget that provides a complete user registration form with
/// validation, error handling, and integration with the authentication system
/// via [AuthProvider] [web:114][web:118].
///
/// ## Features
///
/// - **Form Validation**: Validates all required fields using [GlobalKey<FormState>] [web:114]
/// - **Password Confirmation**: Ensures passwords match before submission [web:118]
/// - **Gender Selection**: Provides radio button-style gender selection UI
/// - **Loading States**: Shows loading indicator during registration [web:118]
/// - **Error Display**: Presents error messages in a visually distinct container [web:118]
/// - **Responsive Layout**: Uses [SingleChildScrollView] for keyboard-friendly scrolling [web:114]
///
/// ## Form Fields
///
/// - First Name (required)
/// - Last Name (required)
/// - Email (required, validated format)
/// - Password (required, minimum 8 characters) [web:118]
/// - Confirm Password (required, must match password) [web:118]
/// - Gender selection (Homme/Femme/Autre)
///
/// ## State Management
///
/// This screen uses [Provider] to access [AuthProvider] for registration operations.
/// Upon successful registration, navigates to '/home' route [web:114][web:118].
///
/// Example usage:
/// ```dart
/// Navigator.of(context).pushNamed('/register');
/// ```
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

/// State class for [RegisterScreen].
///
/// Manages form state, validation, text controllers, and registration logic.
/// Implements proper lifecycle management with controller disposal [web:120].
class _RegisterScreenState extends State<RegisterScreen> {
  /// Text controller for the first name input field.
  ///
  /// Must be disposed in [dispose] to prevent memory leaks [web:120].
  final _firstNameController = TextEditingController();

  /// Text controller for the last name input field.
  ///
  /// Must be disposed in [dispose] to prevent memory leaks [web:120].
  final _lastNameController = TextEditingController();

  /// Text controller for the email input field.
  ///
  /// Must be disposed in [dispose] to prevent memory leaks [web:120].
  final _emailController = TextEditingController();

  /// Text controller for the password input field.
  ///
  /// Must be disposed in [dispose] to prevent memory leaks [web:120].
  final _passwordController = TextEditingController();

  /// Text controller for the password confirmation input field.
  ///
  /// Used to verify password match before submission [web:118].
  /// Must be disposed in [dispose] to prevent memory leaks [web:120].
  final _confirmPasswordController = TextEditingController();

  /// Global key for form validation.
  ///
  /// Allows triggering validation on all [TextFormField] widgets
  /// within the form using `_formKey.currentState!.validate()` [web:114].
  final _formKey = GlobalKey<FormState>();

  /// Currently selected gender option.
  ///
  /// Defaults to 'Autre' (Other). Options: 'Homme', 'Femme', 'Autre'.
  String _selectedGender = 'Autre';

  /// Loading state indicator.
  ///
  /// When true, displays a loading spinner and disables the submit button
  /// to prevent duplicate submissions [web:118].
  bool _isLoading = false;

  /// Current error message to display.
  ///
  /// Set when registration fails. Displayed in a red error container
  /// above the form fields. Null when no error is present [web:118].
  String? _errorMessage;

  @override
  void dispose() {
    /// Disposes all text controllers to free resources.
    ///
    /// Critical for preventing memory leaks and "controller used after
    /// being disposed" errors [web:120]. Called automatically when the
    /// widget is removed from the widget tree.
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handles registration form submission.
  ///
  /// Validates all form fields, displays loading state, calls [AuthProvider.register],
  /// and navigates to home on success or shows error message on failure [web:114][web:118].
  ///
  /// **Flow:**
  /// 1. Validates all form fields using [GlobalKey<FormState>] [web:114]
  /// 2. Sets loading state and clears previous errors
  /// 3. Calls [AuthProvider.register] with form data
  /// 4. On success: Navigates to '/home' route
  /// 5. On error: Displays error message to user [web:118]
  /// 6. Finally: Resets loading state
  ///
  /// **Error Handling:**
  /// Catches all exceptions from registration and displays them as
  /// user-friendly error messages [web:118].
  Future<void> _handleRegister() async {
    // Validate all form fields before submission [web:114]
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call authentication provider to register user [web:114][web:118]
      await context.read<AuthProvider>().register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            birthDate: '',
            gender: _selectedGender,
          );

      // Navigate to home screen on successful registration
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      // Display error message to user [web:118]
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // Reset loading state (check mounted to avoid setState after disposal) [web:120]
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
        decoration: const BoxDecoration(color: Color(0xFF1B3D2F)),
        child: SafeArea(
          child: SingleChildScrollView(
            // Always scrollable for keyboard accessibility [web:114]
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // Ensure content fills available height [web:114]
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo section with navigation to home
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                        child: Image.asset(
                          'lib/core/theme/logo-color.png',
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // Registration form card
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

                              // Form title
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

                              // Error message display [web:118]
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

                              // Name fields (side by side for space efficiency)
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

                              // Email field with format validation [web:114][web:118]
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

                              // Password field with minimum length validation [web:118]
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

                              // Password confirmation with match validation [web:118]
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

                              const SizedBox(height: 16),

                              // Gender selection (radio button-style UI)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Genre *',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildGenderOption('Homme'),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildGenderOption('Femme'),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildGenderOption('Autre'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Submit button with loading state [web:118]
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _handleRegister,
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

                              // Navigation to login screen
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushReplacementNamed('/login');
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

  /// Builds a text input field with underline border style.
  ///
  /// Creates a labeled [TextFormField] with validation support and
  /// consistent styling throughout the registration form [web:114].
  ///
  /// **Parameters:**
  /// - [controller]: [TextEditingController] for managing field value [web:120]
  /// - [label]: Field label displayed above the input
  /// - [hint]: Optional placeholder text (currently unused)
  /// - [obscureText]: If true, masks input for passwords [web:114]
  /// - [keyboardType]: Keyboard type for input optimization [web:114]
  /// - [validator]: Validation function returning error message or null [web:114]
  ///
  /// **Returns:** A [Column] containing the label and [TextFormField]
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
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 16),
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
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }

  /// Builds a selectable gender option button.
  ///
  /// Creates a radio button-style selector that visually indicates
  /// the selected state with different colors and border styles.
  ///
  /// **Parameters:**
  /// - [gender]: The gender option this button represents ('Homme', 'Femme', 'Autre')
  ///
  /// **Returns:** A [GestureDetector] wrapped [Container] with selection styling
  Widget _buildGenderOption(String gender) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
          ),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
