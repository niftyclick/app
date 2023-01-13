import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nifty_click_app/constants.dart';
import 'package:nifty_click_app/screens/camera_screen.dart';
import 'package:nifty_click_app/screens/display_and_mint.dart';
import 'package:nifty_click_app/screens/nft_gallery.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:camera/camera.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> camera;
  final String publicKey;

  const HomeScreen({
    Key? key,
    required this.camera,
    required this.publicKey,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    PhotoManager.requestPermissionExtend();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const NFTGallery(),
      floatingActionButton: SpeedDial(
        backgroundColor: orange,
        children: [
          //text widget which prints a public key
          

          SpeedDialChild(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraScreen(
                    camera: widget.camera,
                    publicKey: widget.publicKey,
                  ),
                ),
              );
            },
            labelWidget: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: orange,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          SpeedDialChild(
              onTap: () async {
               try {
                      final image =
                          await _picker.pickImage(source: ImageSource.gallery);

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
            labelWidget: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: orange,
                borderRadius: BorderRadius.circular(100),
              ),
              
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
        activeChild: const Icon(
          Icons.close,
          size: 32,
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 36,
        ),
      ),
    );
  }
}
