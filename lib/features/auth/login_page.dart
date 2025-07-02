import 'package:flutter/material.dart';
import 'package:verdantia/core/utils/garden_utils.dart';
import 'auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

OutlineInputBorder border = OutlineInputBorder(
  borderSide: BorderSide(
    color: Colors.black,
    width: 1.5,
  ),
  borderRadius: BorderRadius.circular(8),
);

InputDecoration inputDecor(String hintText) => InputDecoration(
      hintText: hintText,
      errorBorder: border,
      enabledBorder: border,
      disabledBorder: border,
      focusedBorder: border,
    );

class _LoginPageState extends State<LoginPage> {
  // controllers
  final TextEditingController _emailController = TextEditingController();
  // no email controller for log in
  final TextEditingController _passwordController = TextEditingController();

  String errorText = "";

  Future<void> _login({required AuthCubit authCubit}) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorText = "Email and password cannot be empty";
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // initialize garden if its missing
      await initializeGardenIfNeeded();

      if (!mounted) return;
      // take user to garden screen
      context.go('/garden');
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for this user.';
      } else {
        message = "An unknown error occurred";
      }

      setState(() {
        errorText = message;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final AuthState authState = context.watch<AuthCubit>().state;
    final AuthCubit authCubit = context.read<AuthCubit>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Login"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // email text field
              TextField(
                controller: _emailController,
                decoration: inputDecor("Enter your email here..."),
              ),

              SizedBox(height: 10),

              // password text field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: inputDecor("Enter your password here..."),
              ),

              SizedBox(height: 5),

              // error text
              Text(
                errorText,
                style: TextStyle(color: Colors.red),
              ),

              SizedBox(height: 5),

              // log in button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _login(authCubit: authCubit),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Log in"),
                ),
              ),

              SizedBox(height: 5),

              GestureDetector(
                onTap: () => context.go('/signup'),
                child: Text(
                  "Sign up instead",
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
