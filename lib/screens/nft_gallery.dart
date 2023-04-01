import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nifty_click_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

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
    return FutureBuilder<List>(
      future: () async {
        List nfts = [];
        http.Response response = await http.get(
          Uri.parse(
              "https://api-mainnet.magiceden.dev/v2/wallets/${widget.publicKey}/tokens?offset=0&limit=100&listStatus=both"),
          headers: {
            "accept": "application/json",
            "Authorization": "0478fab5-5d5b-4a3f-a5d7-e56cc570dc33",
          },
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
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        } else {
          if (snapshot.hasData) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: snapshot.data!
                      .map(
                        (nft) => GestureDetector(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: nft.toString(),
                                placeholder: (context, url) {
                                  return Shimmer.fromColors(
                                    baseColor:
                                        const Color.fromRGBO(34, 34, 34, 1),
                                    highlightColor:
                                        const Color.fromARGB(255, 55, 58, 63),
                                    period: const Duration(milliseconds: 850),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            const Color.fromRGBO(34, 34, 34, 1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            );
          } else {
            return const Center(
              child: Text("Cannot fetch NFTs"),
            );
          }
        }
      },
    );
  }
}
