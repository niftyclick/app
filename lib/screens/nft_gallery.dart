import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nifty_click_app/constants.dart';
import 'package:http/http.dart' as http;

class NFTGallery extends StatefulWidget {
  final String publicKey;

  const NFTGallery({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  @override
  State<NFTGallery> createState() => _NFTGalleryState();
}

class _NFTGalleryState extends State<NFTGallery> {
  final JsonDecoder decoder = JsonDecoder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightSilver,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0,
        backgroundColor: lightSilver,
        title: Text(
          "NFT Gallery",
          style: TextStyle(
            fontSize: size,
            fontFamily: GoogleFonts.lato().fontFamily,
            color: darkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List>(
        future: () async {
          List nfts = [];
          http.Response response = await http.get(
            Uri.parse(
                "https://api-devnet.magiceden.dev/v2/wallets/${widget.publicKey}/tokens?offset=0&limit=50"),
          );
          for (var nft in (decoder.convert(response.body) as List)) {
            if (nft != null) {
              if (nft["image"] != "") {
                  nfts.add("${nft["image"]}");
              }
            }
          }
          return nfts;
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: snapshot.data!
                      .map(
                        (nft) => ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image(
                            image: CachedNetworkImageProvider(nft.toString()),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            } else {
              return const Center(
                child: Text("Cannot fetch NFTs"),
              );
            }
          }
        },
      ),
    );
  }
}
