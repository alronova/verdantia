import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verdantia/core/services/firebase_service.dart';
import 'package:verdantia/core/utils/garden_utils.dart';
import 'package:verdantia/features/auth/widgets.dart';
import 'auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

class _SignupPageState extends State<SignupPage> {
  // controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String errorText = "";

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
                    "SIGNUP",
                    style: GoogleFonts.pixelifySans(
                        fontSize: 40, color: Colors.green.shade900),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text(
                      "Join Verdantia - where every click grows a LEAF",
                      style:
                          TextStyle(fontSize: 12, color: Colors.green.shade900),
                    ),
                  ),
                  // username text field
                  TextField(
                    controller: _usernameController,
                    decoration:
                        inputDecor("Username", Icon(Icons.account_circle)),
                  ),

                  SizedBox(height: 10),

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

                      final error = await authCubit.signup(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                        username: _usernameController.text.trim(),
                        context: context,
                      );

                      if (error != null) {
                        setState(() {
                          errorText = error;
                        });
                      }
                    },
                    style: circularBtn,
                    child: Text("Sign up"),
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
        ],
      ),
    );
  }
}
