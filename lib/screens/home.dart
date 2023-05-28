import 'package:flutter/material.dart';
import 'package:sap/screens/home_doctor.dart';
import 'package:sap/screens/home_user.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/widgets/error_text.dart';
import 'package:sap/widgets/gradient_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    super.initState();
    userProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    final user = userProvider.user;
    final isLoading = userProvider.isLoading;
    final errorMessage = userProvider.errorMessage;

    if (isLoading) {
      return const GradientScaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return GradientScaffold(
        body: Center(
          child: ErrorText(text: errorMessage),
        ),
      );
    }

    if (user!.isDoctor) {
      return const DoctorHomeScreen();
    } else {
      return const UserHomeScreen();
    }
  }
}
