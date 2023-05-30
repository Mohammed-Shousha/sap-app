import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/providers/medicines_provider.dart';
import 'package:sap/providers/prescriptions_provider.dart';
import 'package:sap/screens/welcome.dart';
import 'package:sap/utils/constants.dart';
import 'package:sap/utils/shared_preferences_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sap/screens/home.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/utils/palette.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

  await initHiveForFlutter();

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: HttpLink(
        '${Constants.baseUrl}/graphql',
      ),
      cache: GraphQLCache(
        store: HiveStore(),
      ),
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.cacheAndNetwork,
        ),
      ),
    ),
  );

  String userId = await getUserId();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(
            client: client.value,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PrescriptionsProvider(
            client: client.value,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MedicinesProvider(
            client: client.value,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SAP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Palette.primary,
          fontFamily: 'Montserrat',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: userId.isNotEmpty ? const HomeScreen() : const WelcomeScreen(),
      ),
    ),
  );
}
