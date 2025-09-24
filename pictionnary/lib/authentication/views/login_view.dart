import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/input_section.dart';
import '../widgets/input_password_section.dart';

class LoginView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LoginView({super.key, required String title});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  InputSection(
                    controller: emailController,
                    hintText: 'Email',
                  ),
                  InputPasswordSection(
                    controller: passwordController,
                    hintText: 'Password',
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await authViewModel.signIn(emailController.text,passwordController.text);

                        if (authViewModel.user != null) {
                          // Redirection vers l'accueil
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      }
                    },
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Not registered yet?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text("Sign up here!"),
                      ),
                    ],
                  ),
                ],
              ))),
    );
  }
}