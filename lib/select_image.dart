// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pinenacl/x25519.dart';
import 'package:provider/provider.dart';

import 'deep_link_provider.dart';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nifty_click_app/display_and_mint.dart';

class SelectImage extends StatefulWidget {
  final CameraDescription camera;
  final String publicKey;

  const SelectImage({
    Key? key,
    required this.camera,
    required this.publicKey,
  }) : super(key: key);

  @override
  State<SelectImage> createState() => _SelectImageState();
}

class _SelectImageState extends State<SelectImage> {
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
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    DeepLinkProvider provider = DeepLinkProvider();
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Phantom Deeplinking"),
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
                ElevatedButton(
                    onPressed: () async {
                      try {
                        final image = await _picker.pickImage(
                            source: ImageSource.gallery);

                        if (!mounted) return;

                        // If the picture was taken, display it on a new screen.
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DisplayAndMint(
                              imagePath: image!.path,
                              publicKey: widget.publicKey,
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
          )),
      floatingActionButton: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 31),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
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
                          publicKey: widget.publicKey,
                        ),
                      ),
                    );
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                  }
                },
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}