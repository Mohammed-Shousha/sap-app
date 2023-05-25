import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/screens/welcome.dart';
import 'package:sap/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sap/screens/home.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/utils/palette.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initHiveForFlutter();

  await dotenv.load(fileName: "assets/.env");

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

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

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(
        client: client.value,
        prefs: prefs,
      ),
      child: GraphQLProvider(
        client: client,
        child: MaterialApp(
          title: 'SAP',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Palette.primary,
            fontFamily: 'Montserrat',
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: isLoggedIn ? const HomeScreen() : const WelcomeScreen(),
        ),
      ),
    ),
  );
}
