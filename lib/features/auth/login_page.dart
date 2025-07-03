import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdantia/core/services/firebase_service.dart';
import 'package:verdantia/core/utils/garden_utils.dart';
import 'package:verdantia/features/auth/widgets.dart';
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

class _LoginPageState extends State<LoginPage> {
  // controllers
  final TextEditingController _emailController = TextEditingController();
  // no email controller for log in
  final TextEditingController _passwordController = TextEditingController();
  // auth cubit instance

  String errorText = "";

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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/new/auth.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "LOGIN",
                    style: GoogleFonts.pixelifySans(
                        fontSize: 40, color: Colors.green.shade900),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text(
                      "Reconnect with your roots \n - your plants await",
                      style:
                          TextStyle(fontSize: 12, color: Colors.green.shade900),
                    ),
                  ),

                  // email text field
                  TextField(
                    controller: _emailController,
                    decoration: inputDecor("Email", Icon(Icons.email)),
                  ),

                  SizedBox(height: 10),

                  // password text field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: inputDecor("Password", Icon(Icons.key_rounded)),
                  ),

                  SizedBox(height: 5),

                  // error text
                  Text(
                    errorText,
                    style: TextStyle(color: Colors.red),
                  ),

                  SizedBox(height: 5),

                  // log in button
                  ElevatedButton(
                    onPressed: () async {
                      final authCubit = context.read<AuthCubit>();

                      final error = await authCubit.login(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                        context: context,
                      );

                      if (error != null) {
                        setState(() {
                          errorText = error;
                        });
                      }
                    },
                    style: circularBtn,
                    child: Text("Log in"),
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
        ],
      ),
    );
  }
}
