import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sap/widgets/gradient_scaffold.dart';

class QRCodeScreen extends StatelessWidget {
  final String id;

  const QRCodeScreen({
    required this.id,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImage(
              data: id,
              version: QrVersions.auto,
              size: 300,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'ID: $id',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
