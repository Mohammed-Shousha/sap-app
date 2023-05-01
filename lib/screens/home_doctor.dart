import 'package:flutter/material.dart';
import 'package:sap/screens/prescriptions.dart';
import 'package:sap/screens/start.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'add_prescription.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/widgets/custom_list_tile.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return GradientScaffold(
      appBar: AppBar(
        title: Text('Welcome, ${userProvider.user?.name}'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomListTile(
            titleText: 'Create a new prescription',
            leadingIcon: Icons.add,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddPrescriptionForm(),
              ),
            ),
          ),
          CustomListTile(
            titleText: 'View prescription history',
            leadingIcon: Icons.history,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrescriptionsScreen(),
              ),
            ),
          ),
          CustomListTile(
            titleText: 'Logout',
            leadingIcon: Icons.logout,
            onTap: () => {
              userProvider.logout(),
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const StartScreen(),
                ),
                (route) => false,
              )
            },
          ),
        ],
      ),
    );
  }
}
