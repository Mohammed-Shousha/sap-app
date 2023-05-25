import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sap/widgets/gradient_scaffold.dart';

class QRCodeScreen extends StatelessWidget {
  final String id;
  final bool isUser;

  const QRCodeScreen({
    super.key,
    required this.id,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            QrImage(
              data: id,
              version: QrVersions.auto,
              size: 300,
            ),
            const SizedBox(height: 16),
            Text(
              'ID: $id',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            isUser
                ? const Text(
                    'Show this QR code to your doctor to get your prescription',
                    style: TextStyle(fontSize: 20),
                  )
                : const Text(
                    'Scan this QR code using SAP machine to get your medicines',
                    style: TextStyle(fontSize: 20),
                  ),
          ],
        ),
      ),
    );
  }
}
