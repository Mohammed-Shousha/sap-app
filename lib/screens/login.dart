import 'package:flutter/material.dart';
import 'package:sap/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/screens/admin.dart';
import 'package:sap/utils/dialogs/error_dialog.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    // admin login
    if (!email.contains('@')) {
      await userProvider.adminLogin(email, password);

      if (userProvider.errorMessage.isNotEmpty && mounted) {
        showErrorDialog(context, userProvider.errorMessage);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminScreen(),
          ),
          (route) => false,
        );
      }

      return;
    }

    await userProvider.login(email, password);

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
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
          CustomButton(
            text: 'Login',
            onPressed: _handleLogin,
          ),
        ],
      ),
    );
  }
}
