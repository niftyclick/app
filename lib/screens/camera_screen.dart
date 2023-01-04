// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinenacl/x25519.dart';
import 'package:provider/provider.dart';
import 'package:nifty_click_app/constants.dart';
import '../deep_link_provider.dart';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nifty_click_app/screens/display_and_mint.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  // final String publicKey;

  const CameraScreen({
    Key? key,
    required this.camera,
    // required this.publicKey,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();

  final List<Widget> logs = [];
  late PrivateKey sk;
  late PublicKey pk;
  String walletAddr = "";
  String session = "";
  late Box sharedSecret;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,

      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    DeepLinkProvider provider = DeepLinkProvider();
    return MaterialApp(
        home: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0,
        backgroundColor: lightSilver,
        title: Text(
          "Camera",
          style: TextStyle(
            fontSize: size,
            color: darkGrey,
            fontFamily: GoogleFonts.lato().fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Provider<DeepLinkProvider>(
        create: (context) => provider,
        dispose: (context, provider) => provider.dispose(),
        child: Center(
          child: Column(
            children: [
              FutureBuilder(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the Future is complete, display the preview.
                    return CameraPreview(_controller);
                  } else {
                    // Otherwise, display a loading indicator.
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              const SizedBox(height: 20),
             ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    textStyle: TextStyle(
                        color: lightSilver,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontSize: 17),
                  ),
                  onPressed: () async {
                    try {
                      final image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      
                      if(image == null) return;
                      if (!mounted) return;

                      // If the picture was taken, display it on a new screen.
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DisplayAndMint(
                            imagePath: image.path,
                            // publicKey: widget.publicKey,
                          ),
                        ),
                      );
                    } catch (e) {
                      if (kDebugMode) {
                        print(e);
                      }
                    }
                  },
                  child: const Text("Open Gallery")),
            ],
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                backgroundColor: orange,
                splashColor: orange,
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: lightSilver,
                ),
                onPressed: () async {
                  try {
                    await _initializeControllerFuture;

                    final image = await _controller.takePicture();

                    if (!mounted) return;

                    // If the picture was taken, display it on a new screen.
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayAndMint(
                          imagePath: image.path,
                          // publicKey: widget.publicKey,
                        ),
                      ),
                    );
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
