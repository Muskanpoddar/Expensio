import 'package:Budget_App/view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TextFormEmail extends HookConsumerWidget {
  const TextFormEmail({super.key, required TextEditingController emailField})
    : _emailField = emailField;

  final TextEditingController _emailField;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 350.0,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,

        textAlign: TextAlign.center,
        controller: _emailField,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          prefixIcon: Icon(Icons.email, color: Colors.black, size: 30.0),
          hintText: "Email",
          hintStyle: GoogleFonts.openSans(),
        ),
      ),
    );
  }
}

class TextFormPassword extends HookConsumerWidget {
  const TextFormPassword({
    super.key,
    required TextEditingController passwordField,
    required this.viewModelProvider,
  }) : _passwordField = passwordField;

  final TextEditingController _passwordField;
  final ViewModel viewModelProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 350.0,
      child: TextFormField(
        textAlign: TextAlign.center,
        controller: _passwordField,
        obscureText: viewModelProvider.isObscure,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          prefixIcon: IconButton(
            icon: Icon(
              viewModelProvider.isObscure
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.black,
            ),
            onPressed: () {
              viewModelProvider.toggleObscure();
            },
          ),
          hintText: "Password",
          hintStyle: GoogleFonts.openSans(),
        ),
      ),
    );
  }
}
