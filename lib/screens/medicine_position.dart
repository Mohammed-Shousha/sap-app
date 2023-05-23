import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:sap/models/medicine_model.dart';
import 'package:sap/utils/graphql_queries.dart';
import 'package:sap/utils/palette.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/screens/start.dart';

class MedicinePosition extends StatefulWidget {
  const MedicinePosition({Key? key}) : super(key: key);

  @override
  State<MedicinePosition> createState() => _MedicinePositionState();
}

class _MedicinePositionState extends State<MedicinePosition> {
  MedicineModel? _medicine;
  final int _axisCount = 4;

  Future<void> _scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );
    Logger().i(barcodeScanRes);

    barcodeScanRes = '6419d62f92a9b740d70e70be';

    if (context.mounted) {
      final result = await GraphQLProvider.of(context).value.query(QueryOptions(
            document: gql(GraphQLQueries.getMedicine),
            variables: {
              'medicineId': barcodeScanRes,
            },
          ));

      if (result.hasException && context.mounted) {
        Logger().e(result.exception);
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
              '${result.exception?.graphqlErrors[0].message}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      // Logger().i(result.data!['medicineById']);

      setState(() {
        _medicine = MedicineModel.fromJson(result.data!['medicineById']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const StartScreen(),
              ),
              (route) => false,
            ),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _medicine == null
                ? const SizedBox.shrink()
                : Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Scanned Medicine: ${_medicine?.name}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        const Text("Add the medicine to the position"),
                        Expanded(
                          child: GridView.count(
                            padding: const EdgeInsets.only(top: 10),
                            crossAxisCount: _axisCount,
                            children:
                                List.generate(_axisCount * _axisCount, (index) {
                              final row = index ~/ _axisCount;
                              final col = index % _axisCount;
                              return GridTile(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Palette.primary,
                                    ),
                                    color: row == _medicine?.position['row'] &&
                                            col == _medicine?.position['col']
                                        ? Palette.primary
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                      child: Text(
                                    '$row, $col',
                                    style: const TextStyle(fontSize: 18),
                                  )),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
            CustomButton(
              onPressed: _scanBarcode,
              text: 'Scan Barcode',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
