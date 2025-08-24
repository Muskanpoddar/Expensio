import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_button/sign_button.dart';

import '../view_model.dart';
import '../components.dart';

class RegisterButton extends HookConsumerWidget {
  final ViewModel viewModelProvider;
  final TextEditingController emailField;
  final TextEditingController passwordField;

  const RegisterButton({
    super.key,
    required this.viewModelProvider,
    required this.emailField,
    required this.passwordField,
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

  const LoginButton({
    super.key,
    required this.viewModelProvider,
    required this.emailField,
    required this.passwordField,
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
          );
        },
      ),
    );
  }
}

class SignInbutton extends StatelessWidget {
  final ViewModel viewModelProvider;

  const SignInbutton({super.key, required this.viewModelProvider});

  @override
  Widget build(BuildContext context) {
    return SignInButton(
      buttonType: ButtonType.google,
      btnColor: Colors.black,
      btnTextColor: Colors.white,
      buttonSize: ButtonSize.medium,
      onPressed: () async {
        if (kIsWeb) {
          await viewModelProvider.signInWithGoogleWeb(context);
        } else {
          await viewModelProvider.signInWithGoogleMobile(context);
        }
      },
    );
  }
}
