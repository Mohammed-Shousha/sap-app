import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:sap/models/medicine_model.dart';

class MedicinePosition extends StatefulWidget {
  const MedicinePosition({Key? key}) : super(key: key);

  @override
  State<MedicinePosition> createState() => _MedicinePositionState();
}

class _MedicinePositionState extends State<MedicinePosition> {
  MedicineModel? _medicine;

  Future<void> _scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    // barcodeScanRes = '6419d62f92a9b740d70e70be';

    // Logger().i(barcodeScanRes);

    if (context.mounted) {
      final result = await GraphQLProvider.of(context).value.query(QueryOptions(
            document: gql(r'''
              query MedicineById($medicineId: ID!){
                medicineById(id: $medicineId) {
                  _id
                  name
                  availableQuantity
                  otc
                  position {
                    row
                    col
                  }
                }
              }
            '''),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _scanBarcode,
              child: const Text('Scan Barcode'),
            ),
            const SizedBox(height: 16),
            _medicine == null
                ? const SizedBox.shrink()
                : Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Scanned Barcode: ${_medicine?.name}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 4,
                            children: List.generate(16, (index) {
                              final row = index ~/ 4;
                              final col = index % 4;
                              return GridTile(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    color:
                                        row == _medicine?.position['row'] - 1 &&
                                                col ==
                                                    _medicine?.position['col'] -
                                                        1
                                            ? Colors.green
                                            : Colors.transparent,
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${row + 1}${col + 1}',
                                    style: const TextStyle(fontSize: 18),
                                  )),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
