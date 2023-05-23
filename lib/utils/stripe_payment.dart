import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sap/utils/constants.dart';
import 'package:sap/utils/palette.dart';
import 'package:http/http.dart' as http;

Map<String, dynamic>? paymentIntent;

PaymentSheetAppearance paymentSheetAppearance = const PaymentSheetAppearance(
  colors: PaymentSheetAppearanceColors(
    background: Palette.primary,
    primary: Color(0xFFEFEFEF),
    primaryText: Color(0xFFEFEFEF),
    secondaryText: Color(0xFFEFEFEF),
    componentText: Color(0xFF121212),
    placeholderText: Color(0xFF121212),
    componentBackground: Color(0xFFEFEFEF),
  ),
  shapes: PaymentSheetShape(
    borderRadius: 16,
  ),
  primaryButton: PaymentSheetPrimaryButtonAppearance(
    shapes: PaymentSheetPrimaryButtonShape(blurRadius: 16),
    colors: PaymentSheetPrimaryButtonTheme(
      dark: PaymentSheetPrimaryButtonThemeColors(
        background: Color(0xFFEFEFEF),
        text: Palette.primary,
      ),
      light: PaymentSheetPrimaryButtonThemeColors(
        background: Color(0xFFEFEFEF),
        text: Palette.primary,
      ),
    ),
  ),
);

Future<bool> makePayment(num amount, String prescriptionId) async {
  paymentIntent = await createPaymentIntent(amount);

  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      paymentIntentClientSecret: paymentIntent!['paymentIntent'],
      merchantDisplayName: 'SAP',
      appearance: paymentSheetAppearance,
    ),
  );

  await displayPaymentSheet(prescriptionId);

  return true;
}

Future<Map<String, dynamic>> createPaymentIntent(num amount) async {
  try {
    var response = await http.post(
      Uri.parse('${Constants.baseUrl}/payment-sheet'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'amount': amount,
      }),
    );
    return json.decode(response.body);
  } catch (e) {
    throw Exception('Payment Error');
  }
}

Future<void> displayPaymentSheet(String prescriptionId) async {
  try {
    await Stripe.instance.presentPaymentSheet().then((value) async {
      var response = await http.put(
        Uri.parse('${Constants.baseUrl}/mark-prescription-paid'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'prescriptionId': prescriptionId,
        }),
      );

      if (response.statusCode == 200) {
        paymentIntent = null;
      } else {
        throw Exception('Payment Error');
      }
    }).onError((error, stackTrace) {
      throw Exception(error);
    });
  } on StripeException {
    throw Exception('Payment Error');
  }
}
