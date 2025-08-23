import 'package:Budget_App/pages/button.dart';
import 'package:Budget_App/pages/text_form_email.dart';
import 'package:Budget_App/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginViewWeb extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController _emailField = useTextEditingController();
    final TextEditingController _passwordField = useTextEditingController();
    final viewModelProvider = ref.watch(viewModel);

    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF), // Soft background
      body: SafeArea(
        child: Row(
          children: [
            // Left Side Image
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Image.asset(
                    "assets/login_image.png",
                    width: deviceWidth / 2.6,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Right Side Form
            Expanded(
              flex: 1,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top Logo
                      Image.asset(
                        "assets/logo.png",
                        width: 200.0,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40.0),

                      // Email
                      TextFormEmail(emailField: _emailField),
                      const SizedBox(height: 20.0),

                      // Password
                      TextFormPassword(
                        passwordField: _passwordField,
                        viewModelProvider: viewModelProvider,
                      ),
                      const SizedBox(height: 30.0),

                      // Register
                      RegisterButton(
                        viewModelProvider: viewModelProvider,
                        emailField: _emailField,
                        passwordField: _passwordField,
                      ),
                      const SizedBox(height: 20.0),

                      // Or
                      Text(
                        "Or",
                        style: GoogleFonts.pacifico(
                          color: Colors.black87,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Login
                      LoginButton(
                        viewModelProvider: viewModelProvider,
                        emailField: _emailField,
                        passwordField: _passwordField,
                      ),
                      const SizedBox(height: 30.0),

                      // Google sign-in
                      SignInbutton(viewModelProvider: viewModelProvider),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
