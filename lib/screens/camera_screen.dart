import 'package:path_provider/path_provider.dart' as path;
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor_plus/image_editor_plus.dart';

import 'package:pinenacl/x25519.dart';
import 'package:provider/provider.dart';
import 'package:nifty_click_app/constants.dart';
import '../deep_link_provider.dart';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:nifty_click_app/screens/display_and_mint.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> camera;
  final String publicKey;

  const CameraScreen({
    Key? key,
    required this.camera,
    required this.publicKey,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? image;
  Uint8List? imageData;

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
      widget.camera[0],
      ResolutionPreset.ultraHigh,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  Future<String> get _localPath async {
    final directory = await path.getTemporaryDirectory();
    return directory.path;
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
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width,
                      child: CameraPreview(_controller),
                    );
                  } else {
                    // Otherwise, display a loading indicator.
                    return const Center(
                        child: CircularProgressIndicator(
                      color: orange,
                    ));
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: GNav(
            rippleColor: orange,
            gap: 0,
            activeColor: Colors.black,
            iconSize: size,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.grey[100]!,
            color: Colors.black,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            tabs: [
              GButton(
                icon: Icons.flip_camera_android_outlined,
                iconColor: black,
                iconActiveColor: lightSilver,
                backgroundColor: orange,
                textColor: lightSilver,
                onPressed: () async {
                  // if camera is front facing, switch to back facing and vice versa
                  if (_controller.description.lensDirection ==
                      CameraLensDirection.back) {
                    setState(() {
                      _controller = CameraController(
                        widget.camera.firstWhere((camera) =>
                            camera.lensDirection == CameraLensDirection.front),
                        ResolutionPreset.ultraHigh,
                        imageFormatGroup: ImageFormatGroup.yuv420,
                      );
                    });
                  } else {
                    setState(() {
                      _controller = CameraController(
                        widget.camera.firstWhere((camera) =>
                            camera.lensDirection == CameraLensDirection.back),
                        ResolutionPreset.ultraHigh,
                        imageFormatGroup: ImageFormatGroup.yuv420,
                      );
                    });
                  }
                  // Next, initialize the controller. This returns a Future.
                  _initializeControllerFuture = _controller.initialize();
                },
              ),
              GButton(
                icon: Icons.camera_alt,
                iconColor: black,
                iconActiveColor: lightSilver,
                backgroundColor: orange,
                textColor: lightSilver,
                onPressed: () async {
                  try {
                    await _initializeControllerFuture;

                    image = await _controller.takePicture();
                    imageData = await image!.readAsBytes();
                    setState(() {});

                    if (!mounted) return;

                    final editedImage = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageEditor(
                          image: imageData,
                        ),
                      ),
                    );

                    final pathImage =
                        "${await _localPath}/editedImage ${DateTime.now()}.png";
                    XFile.fromData(editedImage).saveTo(pathImage);

                    // replace with edited image
                    if (editedImage != null) {
                      setState(() {
                        imageData = editedImage;
                        image = XFile.fromData(editedImage);
                      });
                    }

                    if (!mounted) return;

                    // await Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => DisplayAndMint(
                    //       imagePath: pathImage,
                    //       publicKey: widget.publicKey,
                    //     ),
                    //   ),
                    // );
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
