import 'package:flutter/material.dart';
import 'package:nifty_click_app/constants.dart';

class NFTGallery extends StatefulWidget {
  const NFTGallery({Key? key}) : super(key: key);

  @override
  State<NFTGallery> createState() => _NFTGalleryState();
}

class _NFTGalleryState extends State<NFTGallery> {
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
          "NFT Gallery",
          style: TextStyle(
            fontSize: size,
            color: darkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
