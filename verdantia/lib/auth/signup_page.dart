import 'package:flutter/material.dart';
import './auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
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

class _SignupPageState extends State<SignupPage> {
  // controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String errorText = "";

  Future<void> _signup({required AuthCubit authCubit}) async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      setState(() {
        errorText = "Username, email and password cannot be empty";
      });
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // if (!mounted) return;
      // take user to books screen
      // context.go('/books');
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with this email.';
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
    _usernameController.dispose();
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
        title: Text("Sign up"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // username text field
              TextField(
                controller: _usernameController,
                decoration: inputDecor("Enter your username here..."),
              ),

              SizedBox(height: 10),

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
                  onPressed: () => _signup(authCubit: authCubit),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Sign up"),
                ),
              ),

              SizedBox(height: 5),

              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text(
                  "Login instead",
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
