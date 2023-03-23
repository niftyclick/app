import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nifty_click_app/screens/connect_wallet.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  print(cameras);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cabinet Grotesk',
        scaffoldBackgroundColor: const Color.fromRGBO(34, 34, 34, 1),
      ),
      home: ConnectWallet(
        camera: cameras,
      ),
    ),
  );
}
