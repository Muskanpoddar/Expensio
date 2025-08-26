import 'package:Budget_App/mobile/expense_view_mobile.dart';
import 'package:Budget_App/mobile/login_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_button/sign_button.dart';

import '../view_model.dart';
import '../components.dart';

class RegisterButton extends HookConsumerWidget {
  final ViewModel viewModelProvider;
  final TextEditingController emailField;
  final TextEditingController passwordField;
  final VoidCallback? onRegisterSuccess;

  const RegisterButton({
    super.key,
    required this.viewModelProvider,
    required this.emailField,
    required this.passwordField,
    this.onRegisterSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 50.0,
      width: 180.0,
      child: MaterialButton(
        onPressed: () async {
          await viewModelProvider.createUserWithEmailAndPassword(
            context,
            emailField.text,
            passwordField.text,
            onSuccess: onRegisterSuccess,
          );
        },
        child: OpenSans(text: "Register", size: 20.0, color: Colors.white),
        splashColor: Colors.grey,
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

class LoginButton extends HookConsumerWidget {
  final ViewModel viewModelProvider;
  final TextEditingController emailField;
  final TextEditingController passwordField;
  final VoidCallback? onLoginSuccess;

  const LoginButton({
    super.key,
    required this.viewModelProvider,
    required this.emailField,
    required this.passwordField,
    this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 50.0,
      width: 140.0,
      child: MaterialButton(
        child: OpenSans(text: "Login", size: 24.0, color: Colors.white),
        splashColor: Colors.grey,
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        onPressed: () async {
          await viewModelProvider.signInWithEmailAndPassword(
            context,
            emailField.text,
            passwordField.text,
            onSuccess: onLoginSuccess,
          );
        },
      ),
    );
  }
}

class SignInbutton extends HookConsumerWidget {
  final ViewModel viewModelProvider;
  final VoidCallback? onLoginSuccess;

  const SignInbutton({
    super.key,
    required this.viewModelProvider,
    this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SignInButton(
      buttonType: ButtonType.google,
      btnColor: Colors.black,
      btnTextColor: Colors.white,
      buttonSize: ButtonSize.medium,
      onPressed: () async {
        try {
          await viewModelProvider.signInWithGoogleMobile(
            context,
            onSuccess: onLoginSuccess,
          );
        } catch (e) {
          // Optional: show dialog on failure
          DialogBox(context, "Google Sign-In failed: $e");
        }
      },
    );
  }
}

/// Wrapper to handle navigation after successful login/registration
class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;

  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return ExpenseViewMobile();
    } else {
      return LoginViewMobile(onLoginSuccess: _onLoginSuccess);
    }
  }
}
