import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sap/screens/start.dart';
import 'package:sap/screens/welcome.dart';
import 'package:sap/utils/dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sap/screens/home.dart';
import 'package:sap/providers/user_provider.dart';
import 'package:sap/screens/medicine_position.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initHiveForFlutter();

  Stripe.publishableKey =
      "pk_test_51HVa76KSon2LsBHhXeMkqSJSSmE5ZDAejg6K0DmxFppRgFXJBeZcojemAUXZ2PrQvyRkynin3TS6GZ8iUCQJpiRu00IPu5tsoN";

  await dotenv.load(fileName: "assets/.env");

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: HttpLink(
        'http://192.168.1.18:4040/graphql',
      ),
      cache: GraphQLCache(
        store: HiveStore(),
      ),
    ),
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(
        client: client.value,
      ),
      child: GraphQLProvider(
        client: client,
        child: MaterialApp(
          title: 'SAP',
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          home: isLoggedIn ? const HomePage() : const MedicinePosition(),
        ),
      ),
    ),
  );
}
