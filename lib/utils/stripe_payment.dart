import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

Map<String, dynamic>? paymentIntent;

Future<bool> makePayment(num amount, String prescriptionId) async {
  paymentIntent = await createPaymentIntent(amount);

  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      paymentIntentClientSecret: paymentIntent!['paymentIntent'],
      merchantDisplayName: 'SAP',
    ),
  );

  await displayPaymentSheet(prescriptionId);

  return true;
}

Future<Map<String, dynamic>> createPaymentIntent(num amount) async {
  try {
    var response = await http.post(
      Uri.parse('http://192.168.1.18:4040/payment-sheet'),
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
        Uri.parse('http://192.168.1.18:4040/mark-prescription-paid'),
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
