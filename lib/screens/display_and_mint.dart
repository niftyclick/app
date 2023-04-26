// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:bs58/bs58.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinenacl/x25519.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nifty_click_app/constants.dart';

class DisplayAndMint extends StatefulWidget {
  final String imagePath;
  final String publicKey;
  final PublicKey dappKey;
  final Box sharedSecret;
  final String session;

  const DisplayAndMint({
    Key? key,
    required this.imagePath,
    required this.publicKey,
    required this.dappKey,
    required this.sharedSecret,
    required this.session,
  }) : super(key: key);

  @override
  State<DisplayAndMint> createState() => _DisplayAndMintState();
}

class _DisplayAndMintState extends State<DisplayAndMint> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  bool _loading = false;
  String cid = "";
  String imageIpfs = "";
  String jsonIpfs = "";
  String txUrl = "";
  String buttonText = "Mint as NFT";

  String authToken = dotenv.get("IPFS_TOKEN", fallback: "");
  late String bearer = 'Bearer $authToken';

  late Map<String, String> headers = {
    'Content-Type': 'multipart/form-data',
    'Accept': 'application/json',
    'Authorization': bearer
  };

  var ipfsEndpoint = Uri.https("api.web3.storage", "/upload");

  Future<String> get _localPath async {
    final directory = await path.getTemporaryDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File("${path}metadata.json");
  }

  Future<File> writeCounter(String content) async {
    final file = await _localFile;
    return file.writeAsString(content);
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return null.toString();
    }
  }

  // Get symbol fron name function
  String getSymbol(String name) {
    if (name.length > 2) {
      return name.substring(0, 3).toUpperCase();
    } else {
      return name.substring(0, 2).toUpperCase();
    }
  }

  Future<String> makeJsonString(
      String name, String description, String address, String imageURI) async {
    Map data = {
      "name": name,
      "symbol": getSymbol(name),
      "description": description,
      "properties": {
        "category": "image",
        "creators": [
          {
            "address": address,
            "share": 100,
          },
        ],
        "files": [
          {
            "uri": imageURI,
            "type": "image/png",
          },
        ],
      },
      "image": imageURI
    };

    return jsonEncode(data);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              MediaQuery.of(context).size.height * 0.2,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromRGBO(128, 128, 128, 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Text(
                        'Mint NFT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.imagePath),
                        height: MediaQuery.of(context).size.height * 0.37,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 24,
                      bottom: 12,
                    ),
                    child: Text(
                      "NFT Title",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  TextField(
                    style: const TextStyle(
                      color: white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    controller: _name,
                    obscureText: false,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(119, 119, 119, 0.4),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(119, 119, 119, 0.4),
                        ),
                      ),
                      hintText: 'Pick a cool name for the NFT',
                      hintStyle: const TextStyle(
                        color: Color.fromRGBO(136, 136, 136, 1),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 24,
                      bottom: 12,
                    ),
                    child: Text(
                      "NFT Description",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.11,
                    child: TextField(
                      style: const TextStyle(
                        color: white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      minLines: 3,
                      maxLines: 5,
                      controller: _description,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(119, 119, 119, 0.4),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(119, 119, 119, 0.4),
                          ),
                        ),
                        hintText: 'Write a description for your NFT here...',
                        hintStyle: const TextStyle(
                          color: Color.fromRGBO(136, 136, 136, 1),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        fixedSize: const Size.fromWidth(double.maxFinite),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        disabledBackgroundColor:
                            const Color.fromRGBO(119, 119, 119, 1),
                      ),
                      onPressed: _name.text != "" && _description.text != ""
                          ? () async {
                              setState(() {
                                _loading = true;
                              });

                              final bytes =
                                  File(widget.imagePath).readAsBytesSync();
                              var ipfsRequest =
                                  http.MultipartRequest('POST', ipfsEndpoint);
                              ipfsRequest.headers.addAll(headers);
                              ipfsRequest.files.add(
                                http.MultipartFile.fromBytes('file', bytes,
                                    filename: _name.text),
                              );
                              var res = await ipfsRequest.send();

                              if (res.statusCode == 200) {
                                var response = await res.stream.bytesToString();
                                setState(() {
                                  cid = jsonDecode(response)['cid'];
                                  imageIpfs = "https://$cid.ipfs.w3s.link";
                                });
                                if (kDebugMode) {
                                  print(imageIpfs);
                                  print("Image uploaded to IPFS.");
                                }
                              } else {
                                if (kDebugMode) {
                                  print(res.statusCode);
                                }
                              }
                              if (kDebugMode) {
                                print("Uploading JSON.");
                              }

                              imageIpfs != "" && widget.publicKey != ""
                                  ? await writeCounter(await makeJsonString(
                                      _name.text,
                                      _description.text,
                                      widget.publicKey,
                                      imageIpfs))
                                  : print("No image");

                              final jsonFile = await _localFile;
                              setState(() {});
                              final jsonBytes = jsonFile.readAsBytesSync();
                              var jsonRequest =
                                  http.MultipartRequest('POST', ipfsEndpoint);
                              jsonRequest.headers.addAll(headers);
                              jsonRequest.files.add(
                                  http.MultipartFile.fromBytes(
                                      'file', jsonBytes,
                                      filename: "metadata.json"));
                              var jsonRes = await jsonRequest.send();
                              if (jsonRes.statusCode == 200) {
                                var response =
                                    await jsonRes.stream.bytesToString();
                                setState(() {
                                  cid = jsonDecode(response)["cid"];
                                  jsonIpfs = "https://$cid.ipfs.w3s.link";
                                });
                                if (kDebugMode) {
                                  print(jsonIpfs);
                                }
                              } else {
                                if (kDebugMode) {
                                  print(jsonRes.reasonPhrase);
                                }
                              }

                              if (kDebugMode) {
                                print("Uploaded JSON to IPFS.");
                                print("Creating NFT using CandyPay API.");
                              }

                              JsonEncoder encoder = const JsonEncoder();

                              if (jsonIpfs != "") {
                                final mintResponse = await http.post(
                                  Uri(
                                    scheme: "https",
                                    host: dotenv.env["BACKEND_URL"],
                                    path: "create",
                                  ),
                                  body: jsonEncode({
                                    "account": widget.publicKey,
                                    "name": _name.text,
                                    "symbol": getSymbol(_name.text),
                                    "seller_fee": "10",
                                    "uri": jsonIpfs,
                                    "network": "mainnet-beta",
                                    "is_base64": false
                                  }),
                                  headers: {"Content-Type": "application/json"},
                                );
                                var nonce = PineNaClUtils.randombytes(24);

                                List<int> data = List<int>.from(
                                    jsonDecode(mintResponse.body)["transaction"]
                                        ["data"]);

                                Map payload = {
                                  "transaction": base58.encode(
                                    Uint8List.fromList(data),
                                  ),
                                  "session": widget.session,
                                };

                                final encryptedMsg = widget.sharedSecret
                                    .encrypt(
                                      encoder
                                          .convert(payload)
                                          .codeUnits
                                          .toUint8List(),
                                      nonce: nonce,
                                    )
                                    .cipherText;

                                Uri url = Uri(
                                  scheme: 'https',
                                  host: 'phantom.app',
                                  path: '/ul/v1/signAndSendTransaction',
                                  queryParameters: {
                                    'dapp_encryption_public_key': base58
                                        .encode(widget.dappKey.asTypedList),
                                    'nonce': base58.encode(nonce),
                                    'redirect_link':
                                        'niftyclick://deeplink.onSignAndSendTransaction',
                                    'payload': base58
                                        .encode(encryptedMsg.toUint8List()),
                                  },
                                );
                                launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                              setState(() {
                                _loading = false;
                              });
                            }
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Mint as NFT',
                            style: TextStyle(
                              color: _name.text != "" && _description.text != ""
                                  ? black
                                  : const Color.fromRGBO(194, 194, 194, 1),
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          if (_loading)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              height: 16,
                              width: 16,
                              child: const CircularProgressIndicator(
                                color: black,
                                strokeWidth: 2,
                              ),
                            )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
