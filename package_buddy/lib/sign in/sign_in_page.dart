import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authentication_service.dart';

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    debugShowCheckedModeBanner:
    false;
    return Scaffold(
      backgroundColor: Color(0xFFFFF9C4),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 70.0, left: 70.0, top: 130.0),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 70.0, left: 70.0),
            child: TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 70.0, left: 70.0, top: 40.0),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              child: GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  height: 70.0,
                  decoration: BoxDecoration(
                      color: Color(0xFF18D191),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 0.0),
                    child: Text(
                      'Sign in with Email',
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  ),
                ),
                onTap: () {
                  print("Test");
                  context.read<AuthenticationService>().signIn(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
