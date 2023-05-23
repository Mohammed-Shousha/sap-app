import 'package:flutter/material.dart';
import 'package:sap/screens/login.dart';
import 'package:sap/screens/register.dart';
import 'package:sap/screens/register_doctor.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/widgets/link_button.dart';

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
          children: const [
            LinkButton(
              text: 'Log in',
              route: LoginScreen(),
            ),
            SizedBox(height: 20.0),
            LinkButton(
              text: 'Register',
              route: RegisterScreen(),
            ),
            SizedBox(height: 20.0),
            LinkButton(
              text: 'Register as Doctor',
              route: RegisterDoctorScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
