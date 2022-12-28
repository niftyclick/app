import 'package:flutter/material.dart';
import 'package:nifty_click_app/constants.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightSilver,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0,
        backgroundColor: lightSilver,
        title: const Text(
          "Gallery",
          style: TextStyle(
            fontSize: 32,
            color: darkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
