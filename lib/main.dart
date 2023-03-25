import 'package:flutter/material.dart';
import 'package:nifty_click_app/screens/connect_wallet.dart';

Future<void> main() async {
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
