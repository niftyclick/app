import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nifty_click_app/display_and_mint.dart';

class CameraPreviewScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraPreviewScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  int? selectedCameraIdx;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
              const SizedBox(height: 40),

            ElevatedButton(
                onPressed: () async {
                  try {
                    final image =
                        await _picker.pickImage(source: ImageSource.gallery);

                    if (!mounted) return;

                    // If the picture was taken, display it on a new screen.
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayAndMint(
                          imagePath: image!.path,
                        ),
                      ),
                    );
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                  }
                },
                child: const Text("Open Gallery"))
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 31),
            child: 
          // Align(
          //     alignment: Alignment.bottomLeft,
          //     child: FloatingActionButton(
          //       onPressed: () => {
          //         // switch camera direction from rear to front
          //         // and vice versa
          //         _controller.value.deviceOrientation == CameraLensDirection.back
          //             ? 



          //       },
          //       child: _controller.value.deviceOrientation ==
          //               CameraLensDirection.back
          //           ? const Icon(Icons.camera_front)
          //           : const Icon(Icons.camera_rear),
          //     ),
          //   ),
          // ),
          Align(
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

        ]

      ),
    );
  }
}
