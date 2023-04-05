import 'package:flutter/material.dart';
import 'package:sap/screens/home_doctor.dart';
import 'package:sap/screens/home_user.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    userProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (userProvider.user!.isDoctor) {
      return const DoctorHomePage();
    } else {
      return const UserHomePage();
    }
  }
}
