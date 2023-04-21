import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nifty_click_app/screens/connect_wallet.dart';
import 'package:nifty_click_app/shared_prefs.dart';

Future<void> main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  SharedPrefs.init();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cabinet Grotesk',
        scaffoldBackgroundColor: const Color.fromRGBO(34, 34, 34, 1),
      ),
      home: const ConnectWallet(),
    ),
  );
}
