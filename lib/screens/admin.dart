import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sap/providers/medicines_provider.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/utils/constants.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:sap/models/medicine_model.dart';
import 'package:sap/utils/dialogs/error_dialog.dart';
import 'package:sap/utils/dialogs/logout_dialog.dart';
import 'package:sap/utils/dialogs/success_dialog.dart';
import 'package:sap/utils/palette.dart';
import 'package:sap/widgets/custom_button.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/screens/start.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Medicine? _medicine;
  bool _isOpen = false;
  int _addedQuantity = 0;

  Future<void> _scanMedicineBarcode() async {
    if (_isOpen) {
      showErrorDialog(context, 'Please submit the current medicine first');
      return;
    }

    String medicineBarcode = await FlutterBarcodeScanner.scanBarcode(
      '#3BBDB1',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    if (medicineBarcode == '-1') {
      return;
    }

    if (mounted) {
      MedicinesProvider medicinesProvider =
          Provider.of<MedicinesProvider>(context, listen: false);

      await medicinesProvider.getMedicine(medicineBarcode);

      final medicine = medicinesProvider.medicine;

      final errorMessage = medicinesProvider.errorMessage;

      if (errorMessage.isNotEmpty && mounted) {
        showErrorDialog(context, errorMessage);
      } else {
        setState(() {
          _medicine = medicine;
        });
      }
    }
  }

  Future<void> _submit() async {
    MedicinesProvider medicinesProvider =
        Provider.of<MedicinesProvider>(context, listen: false);

    await medicinesProvider.updateMedicine(
      _medicine!.id,
      _addedQuantity,
    );

    final errorMessage = medicinesProvider.errorMessage;

    if (errorMessage.isNotEmpty && mounted) {
      showErrorDialog(context, errorMessage);
    } else {
      showSuccessDialog(context, 'Medicines added successfully');
    }

    await _closeShelf();
  }

  Future<void> _openShelf() async {
    final opened = await _shelfAction(ShelfAction.open);

    if (opened && mounted) {
      showSuccessDialog(context, 'Shelf opened successfully');
      setState(() {
        _isOpen = true;
      });
    }
  }

  Future<void> _closeShelf() async {
    final closed = await _shelfAction(ShelfAction.close);

    if (closed && mounted) {
      showSuccessDialog(context, 'Shelf closed successfully');
      setState(() {
        _medicine = null;
        _isOpen = false;
        _addedQuantity = 0;
      });
    }
  }

  Future<bool> _shelfAction(ShelfAction action) async {
    final response = await http.post(
      Uri.parse(Constants.shelfActionUrl(action)),
      body: json.encode({
        'row': _medicine!.position!['row'],
        'col': _medicine!.position!['col'],
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final result = json.decode(response.body);

    if (response.statusCode != 200 && mounted) {
      showErrorDialog(context, result['detail']);
      return false;
    } else {
      return true;
    }
  }

  void _incrementCounter() {
    final int canBeAddedQuantity =
        Constants.shelfCapacity - _medicine!.availableQuantity!;

    if (_addedQuantity < canBeAddedQuantity) {
      setState(() {
        _addedQuantity++;
      });
    } else {
      showErrorDialog(
        context,
        canBeAddedQuantity > 0
            ? 'Cannot add more than $canBeAddedQuantity packs'
            : 'Shelf is full',
      );
    }
  }

  void _decrementCounter() {
    if (_addedQuantity > 0) {
      setState(() {
        _addedQuantity--;
      });
    }
  }

  void _handleLogout() async {
    final shouldLogout = await showLogoutDialog(context);
    if (shouldLogout && mounted) {
      context.read<UserProvider>().logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const StartScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(
            onPressed: _handleLogout,
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
                ? const SizedBox()
                : Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Scanned Medicine: ${_medicine?.name}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Add the medicine to the selected cell",
                        ),
                        Text(
                          'Row: ${(_medicine!.position!['row'] + 1)}, '
                          'Column: ${(_medicine!.position!['col'] + 1)}',
                        ),
                        Expanded(
                          child: GridView.count(
                            childAspectRatio: 0.5,
                            padding: const EdgeInsets.only(top: 10),
                            crossAxisCount: Constants.colCount,
                            children: List.generate(
                              Constants.rowCount * Constants.colCount,
                              (index) {
                                final row = index ~/ Constants.colCount;
                                final col = index % Constants.colCount;
                                return GridTile(
                                  header: const SizedBox(height: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Palette.primary,
                                      ),
                                      color: row ==
                                                  _medicine?.position?['row'] &&
                                              col == _medicine?.position?['col']
                                          ? Palette.primary
                                          : Colors.transparent,
                                    ),
                                    child: const SizedBox(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        _isOpen
                            ? Column(
                                children: [
                                  const SizedBox(height: 16),
                                  const Text("Added Quantity:"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: _decrementCounter,
                                      ),
                                      Text(
                                        '$_addedQuantity',
                                        style: const TextStyle(fontSize: 24.0),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: _incrementCounter,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Consumer<MedicinesProvider>(
                                    builder: (context, medicinesProvider, _) {
                                      return CustomButton(
                                        text: 'Submit',
                                        onPressed: _submit,
                                        isLoading: medicinesProvider.isLoading,
                                      );
                                    },
                                  ),
                                ],
                              )
                            : CustomButton(
                                text: 'Open',
                                onPressed: _openShelf,
                              ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
            Consumer<MedicinesProvider>(
              builder: (context, medicinesProvider, _) {
                return CustomButton(
                  text: 'Scan Medicine Barcode',
                  onPressed: _scanMedicineBarcode,
                  isLoading: medicinesProvider.isLoading,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
