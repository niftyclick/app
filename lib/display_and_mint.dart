// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DisplayAndMint extends StatefulWidget {
  final String imagePath;
  final String publicKey;

  const DisplayAndMint({
    Key? key,
    required this.imagePath,
    required this.publicKey,
  }) : super(key: key);

  @override
  State<DisplayAndMint> createState() => _DisplayAndMintState();
}

class _DisplayAndMintState extends State<DisplayAndMint> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  String cid = "";
  String imageIpfs = "";
  String jsonIpfs = "";
  String txUrl = "";

  Map<String, String> headers = {
    'Content-Type': 'multipart/form-data',
    'Accept': 'application/json',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweGQyNzBiNTY0Q0U2MjViNmM1RjA3MGY0MDMxNWQzZDZCOUU5MDg1NmMiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NjA1NjUyOTYzNzEsIm5hbWUiOiJpbWFnZXMifQ.X4HTihDzCJGTEDX894LoCKymlZoRlvFDNa_IhyaBnMo',
  };

  var ipfsEndpoint = Uri.https("api.web3.storage", "/upload");
  var candyPayEndpoint = Uri.https(
      "public-api.candypay.fun", "/api/v1/integrations/niftyclick/generate");

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
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.file(
              File(widget.imagePath),
              height: 400,
              width: 350,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _name,
              obscureText: false,
              textAlign: TextAlign.left,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'NFT Title',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _description,
              obscureText: false,
              textAlign: TextAlign.left,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Description',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print("Uploading Image.");
                final bytes = File(widget.imagePath).readAsBytesSync();
                var ipfsRequest = http.MultipartRequest('POST', ipfsEndpoint);
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
                  print(imageIpfs);
                  print("Image uploaded to IPFS.");
                } else {
                  print(res.statusCode);
                }
                print("Uploading JSON.");
                print(widget.publicKey);
                imageIpfs != "" && widget.publicKey != ""
                    ? await writeCounter(await makeJsonString(_name.text,
                        _description.text, widget.publicKey, imageIpfs))
                    : print("No image");
                final jsonFile = await _localFile;
                setState(() {});
                final jsonBytes = jsonFile.readAsBytesSync();
                var jsonRequest = http.MultipartRequest('POST', ipfsEndpoint);
                jsonRequest.headers.addAll(headers);
                jsonRequest.files.add(http.MultipartFile.fromBytes(
                    'file', jsonBytes,
                    filename: "metadata.json"));
                var jsonRes = await jsonRequest.send();
                if (jsonRes.statusCode == 200) {
                  var response = await jsonRes.stream.bytesToString();
                  setState(() {
                    cid = jsonDecode(response)["cid"];
                    jsonIpfs = "https://$cid.ipfs.w3s.link";
                  });
                  print(jsonIpfs);
                } else {
                  print(jsonRes.reasonPhrase);
                }

                print("Uploaded JSON to IPFS.");

                print("Creating NFT using CandyPay API.");

                if (jsonIpfs != "") {
                  var candyPayResponse = await http.post(
                    candyPayEndpoint,
                    headers: <String, String>{
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer xDBywyRp4y75oVxYQBby3',
                    },
                    body: jsonEncode(<String, dynamic>{
                      "name": _name.text,
                      "symbol": getSymbol(_name.text),
                      "uri": jsonIpfs,
                      "collection_size": 1,
                      "seller_fee": 10,
                      "network": "devnet",
                      "label": "Niftyclick"
                    }),
                  );

                  if (candyPayResponse.statusCode == 200) {
                    var body = candyPayResponse.body;
                    print(body);
                    setState(() {
                      txUrl = jsonDecode(body)["metadata"]["solana_url"];
                    });
                  } else {
                    print(candyPayResponse.statusCode);
                  }

                  if (txUrl != "") {
                    print("Got Transaction. Opening Phantom...");
                    print(txUrl);
                    await launchUrl(Uri.parse(txUrl));
                    print("Minting Done.");
                  }
                } else {
                  print("No JSON");
                }
              },
              child: const Text('Mint as NFT'),
            ),
          ],
        ),
      ),
    );
  }
}
