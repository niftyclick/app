import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nifty_click_app/screens/display_and_mint.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:camera/camera.dart';

class Dashboard extends StatefulWidget {
  final List<CameraDescription> camera;
  final String publicKey;

  const Dashboard({
    Key? key,
    required this.camera,
    required this.publicKey,
  }) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    PhotoManager.requestPermissionExtend();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color.fromRGBO(128, 128, 128, 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        "${widget.publicKey.substring(0, 3)}...${widget.publicKey.substring(widget.publicKey.length - 3)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.maxFinite,
                margin: const EdgeInsets.only(top: 28, bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(54, 54, 54, 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromRGBO(119, 119, 119, 0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(119, 119, 119, 0.2),
                        borderRadius: BorderRadius.circular(10000),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const Text(
                      "Capture or select image and mint as NFT",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(194, 194, 194, 1),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: TextButton(
                        onPressed: () async {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Wrap(
                                  direction: Axis.vertical,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        final image = await _picker.pickImage(
                                          source: ImageSource.camera,
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        fixedSize: Size.fromWidth(
                                          MediaQuery.of(context).size.width,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text(
                                        "Camera",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          final image = await _picker.pickImage(
                                            source: ImageSource.gallery,
                                          );
                                          if (!mounted) return;
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DisplayAndMint(
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
                                      style: TextButton.styleFrom(
                                        fixedSize: Size.fromWidth(
                                          MediaQuery.of(context).size.width,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text(
                                        "Choose from gallery",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            isScrollControlled: false,
                            enableDrag: false,
                            backgroundColor:
                                const Color.fromRGBO(54, 54, 54, 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: const BorderSide(
                                color: Color.fromRGBO(119, 119, 119, 0.4),
                                width: 1,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          fixedSize: const Size.fromWidth(double.maxFinite),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor:
                              const Color.fromRGBO(201, 250, 117, 1),
                        ),
                        child: const Text(
                          "Upload Image",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
