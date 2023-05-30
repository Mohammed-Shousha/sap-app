import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/screens/home.dart';
import 'package:sap/utils/dialogs/error_dialog.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/custom_text_field.dart';
import 'package:sap/widgets/gradient_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleRegister() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    await userProvider.register(name, email, password);

    if (userProvider.errorMessage.isNotEmpty && mounted) {
      showErrorDialog(context, userProvider.errorMessage);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          CustomTextField(
            label: 'Name',
            controller: _nameController,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Password',
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 32),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              return CustomButton(
                text: 'Register',
                onPressed: _handleRegister,
                isLoading: userProvider.isLoading,
              );
            },
          ),
        ],
      ),
    );
  }
}
