import 'package:flutter/material.dart';
import 'package:sap/screens/prescriptions.dart';
import 'package:sap/screens/qr.dart';
import 'package:provider/provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/widgets/logout_list_tile.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/widgets/link_list_tile.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${userProvider.user?.name}',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LinkListTile(
            titleText: 'View prescription history',
            leadingIcon: Icons.history,
            route: PrescriptionsScreen(),
          ),
          LinkListTile(
            titleText: 'View QR Code',
            leadingIcon: Icons.qr_code,
            route: QRCodeScreen(
              id: userProvider.user!.id,
              isUser: true,
            ),
          ),
          const LogoutListTile(),
        ],
      ),
    );
  }
}