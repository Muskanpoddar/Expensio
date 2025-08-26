import 'package:Budget_App/pages/button.dart';
import 'package:Budget_App/pages/text_form.dart';
import 'package:Budget_App/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginViewMobile extends HookConsumerWidget {
  final VoidCallback? onLoginSuccess;

  const LoginViewMobile({Key? key, this.onLoginSuccess}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController _emailField = useTextEditingController();
    final TextEditingController _passwordField = useTextEditingController();

    final vm = ref.watch(viewModel); // your ViewModel provider
    final double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: deviceHeight * 0.1),

                // Logo
                Center(
                  child: Image.asset(
                    "assets/logo.png",
                    fit: BoxFit.contain,
                    width: 180.0,
                  ),
                ),

                const SizedBox(height: 40.0),

                // Email Field
                TextFormEmail(emailField: _emailField),
                const SizedBox(height: 20.0),

                // Password Field
                TextFormPassword(
                  passwordField: _passwordField,
                  viewModelProvider: vm,
                ),
                const SizedBox(height: 30.0),

                // Register Button
                RegisterButton(
                  viewModelProvider: vm,
                  emailField: _emailField,
                  passwordField: _passwordField,
                  onRegisterSuccess: onLoginSuccess,
                ),
                const SizedBox(height: 20.0),

                // OR text
                Text(
                  "Or",
                  style: GoogleFonts.pacifico(
                    color: Colors.black87,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 20.0),

                // Login Button
                LoginButton(
                  viewModelProvider: vm,
                  emailField: _emailField,
                  passwordField: _passwordField,
                  onLoginSuccess: onLoginSuccess,
                ),
                const SizedBox(height: 30.0),

                // Google Sign-In Button
                SignInbutton(
                  viewModelProvider: vm,
                  onLoginSuccess: onLoginSuccess,
                ),
                const SizedBox(height: 40.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
