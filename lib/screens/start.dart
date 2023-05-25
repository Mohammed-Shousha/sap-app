import 'package:flutter/material.dart';
import 'package:sap/screens/login.dart';
import 'package:sap/screens/register.dart';
import 'package:sap/screens/register_doctor.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/gradient_scaffold.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Start'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Log in',
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                )
              },
            ),
            const SizedBox(height: 20.0),
            CustomButton(
              text: 'Register',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            CustomButton(
              text: 'Register as Doctor',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterDoctorScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
