import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:nifty_click_app/constants.dart';
import 'package:nifty_click_app/screens/camera_screen.dart';
import 'package:nifty_click_app/screens/gallery.dart';
import 'package:nifty_click_app/screens/nft_gallery.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:camera/camera.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> camera;
  const HomeScreen({Key? key, required this.camera}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    Gallery(),
    NFTGallery(),
  ];

  @override
  void initState() {
    super.initState();
    PhotoManager.requestPermissionExtend();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CameraScreen(
                camera: widget.camera
              )
            )
          );
        },
        backgroundColor: orange,
        splashColor: orange,
        child: const Icon(
          Icons.add_a_photo_outlined,
          color: lightSilver,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: darkGrey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Padding(
       padding: const EdgeInsets.fromLTRB(18, 17, 18, 17),
          child: GNav(
            tabBorderRadius: 16,
            rippleColor: orange,
            gap: 0,
            activeColor: Colors.black,
            iconSize: size,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.grey[100]!,
            color: Colors.black,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            tabs: const [
              GButton(
                icon: Icons.home_outlined,
                text: 'Gallery',
                iconColor: lightSilver,
                iconActiveColor: lightSilver,
                backgroundColor: orange,
                textColor: lightSilver,
              ),
              GButton(
                icon: Icons.stream,
                text: 'NFT Gallery',
                iconColor: lightSilver,
                iconActiveColor: lightSilver,
                backgroundColor: orange,
                textColor: lightSilver,
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
