import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DisplayAndMint extends StatefulWidget {
  final String imagePath;

  const DisplayAndMint({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<DisplayAndMint> createState() => _DisplayAndMintState();
}

class _DisplayAndMintState extends State<DisplayAndMint> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  String cid = "";
  String imageIpfs = "";

  Map<String, String> headers = {
    'Content-Type': 'multipart/form-data',
    'Accept': 'application/json',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweEUwYTI2OTJGM0I2MDNhMTNCYjQyNzMxNTE1ODBDMzZCNTFlODlDY2YiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NjU5MjU5Nzg2ODUsIm5hbWUiOiJuaWZ0eS10cmlhbCJ9.4Bn__ntHrZmdwj5tMxdFa9UiEW6GxBLTB4hT2USNuCc',
  };

  var ipfsEndpoint = Uri.https("api.web3.storage", "/upload");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.file(
                File(widget.imagePath),
              ),
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
              ElevatedButton(
                onPressed: () async {
                  final bytes = File(widget.imagePath).readAsBytesSync();
                  var request = http.MultipartRequest('POST', ipfsEndpoint);
                  request.headers.addAll(headers);
                  request.files.add(
                    http.MultipartFile.fromBytes('file', bytes,
                        filename: _name.text),
                  );
                  var res = await request.send();
                  if (res.statusCode == 200) {
                    var response = await res.stream.bytesToString();
                    setState(() {
                      cid = jsonDecode(response)['cid'];
                      imageIpfs = "https://$cid.ipfs.w3s.link";
                    });
                    print(imageIpfs);
                  } else {
                    print(res.statusCode);
                  }
                },
                child: const Text("MINT"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
