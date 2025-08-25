import 'package:Budget_App/pages/button.dart';
import 'package:Budget_App/pages/text_form.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../view_model.dart';

// where you placed TextFormEmail & TextFormPassword

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider = ref.watch(viewModel);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Budget App",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Email Field
                TextFormEmail(emailField: emailController),
                const SizedBox(height: 16),

                // Password Field
                TextFormPassword(
                  passwordField: passwordController,
                  viewModelProvider: viewModelProvider,
                ),
                const SizedBox(height: 24),

                // Buttons Row (Login + Register)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LoginButton(
                      viewModelProvider: viewModelProvider,
                      emailField: emailController,
                      passwordField: passwordController,
                    ),
                    RegisterButton(
                      viewModelProvider: viewModelProvider,
                      emailField: emailController,
                      passwordField: passwordController,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Divider
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // Google Sign-In
                SignInbutton(viewModelProvider: viewModelProvider),

                const SizedBox(height: 40),
                const Text(
                  "Welcome! Sign in to manage your budget.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
