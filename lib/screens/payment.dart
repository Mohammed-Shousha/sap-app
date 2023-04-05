import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  //  final Stripe _stripe = Stripe.instance;
  // late final PaymentSheet _paymentSheet;
  // bool _isPaymentProcessing = false;

  // @override
  // void initState() {
  //   super.initState();
  //   // _initializeStripe();
  // }

  // Future<void> _initializeStripe() async {
  //   await Stripe.instance.applySettings(
  //     StripeSettings(
  //       publishableKey: '<YOUR_PUBLISHABLE_KEY>',
  //     ),
  //   );
  // }

  // Future<void> _initPaymentSheet() async {
  //   final response = await fetchPaymentSheetUrl();
  //   setState(() {
  //     _paymentSheetUrl = response['data']['paymentSheetUrl'];
  //   });
  // }

  // Future<void> _initPaymentSheet() async {
  //   await _stripe.initPaymentSheet(
  //     paymentSheetParameters: const SetupPaymentSheetParameters(
  //       paymentIntentClientSecret: 'YOUR_PAYMENT_INTENT_CLIENT_SECRET',
  //       style: ThemeMode.light,
  //       // merchantDisplayName: 'Example, Inc.',
  //     ),
  //   );
  //   setState(() {
  //     _paymentSheet = PaymentSheet.instance;
  //   });
  // }

  // Future<void> _presentPaymentSheet() async {
  //   try {
  //     setState(() {
  //       _isPaymentProcessing = true;
  //     });
  //     await _paymentSheet.present();
  //     setState(() {
  //       _isPaymentProcessing = false;
  //     });
  //   } on Exception catch (e) {
  //     setState(() {
  //       _isPaymentProcessing = false;
  //     });
  //     print('Error: $e');
  //   }
  // }

  // Future<Map<String, dynamic>> fetchPaymentSheetUrl() async {
  //   final response = await http.post(
  //     Uri.parse('http://localhost:4040/payment-sheet'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(<String, dynamic>{
  //       'amount': 1000,
  //     }),
  //   );

  //   print(response.body);
  //   return json.decode(response.body);
  // }

  // Future<void> _showPaymentSheet() async {
  //   if (_paymentSheetUrl == null) {
  //     await _initPaymentSheet();
  //   }
  //   try {
  //     final result = await Stripe.instance.initPaymentSheet(
  //       paymentSheetParameters: SetupPaymentSheetParameters(
  //         paymentIntentClientSecret:
  //             _paymentSheetResult.paymentIntent.clientSecret,
  //         merchantDisplayName: 'Your Merchant Name',
  //         customerEphemeralKeySecret: data['ephemeralKey'],
  //         customerId: data['customer'],
  //       ),
  //     );
  //     setState(() {
  //       _paymentSheetResult = result;
  //     });
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  Map<String, dynamic>? paymentIntent;

  Future<Map<String, dynamic>> createPaymentIntent(String amount) async {
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
      // print(json.decode(response.body));
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100.0,
                      ),
                      SizedBox(height: 10.0),
                      Text("Payment Successful!"),
                    ],
                  ),
                ));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException {
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    }
  }

  Future<void> makePayment() async {
    paymentIntent = await createPaymentIntent('10');

    await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
      paymentIntentClientSecret: paymentIntent!['paymentIntent'],
      merchantDisplayName: 'SAP',
    ));

    displayPaymentSheet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => makePayment(),
          child: const Text('Pay'),
        ),
      ),
    );
  }
}
