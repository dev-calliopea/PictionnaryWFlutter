import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/input_section.dart';
import '../widgets/input_password_section.dart';

class RegisterView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                    await authViewModel.register(emailController.text, passwordController.text);
                    if (authViewModel.user != null) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  }
                },
                child: const Text('Register'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already registered ?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text("Log in here!"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}