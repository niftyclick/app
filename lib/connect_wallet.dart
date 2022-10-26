// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:bs58/bs58.dart';
import 'package:flutter/material.dart';
import 'package:nifty_click_app/select_image.dart';
import 'package:pinenacl/x25519.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'deep_link_provider.dart';

import 'package:camera/camera.dart';

class ConnectWallet extends StatefulWidget {
  final CameraDescription camera;

  const ConnectWallet({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  State<ConnectWallet> createState() => _ConnectWalletState();
}

class _ConnectWalletState extends State<ConnectWallet> {
  final List<Widget> logs = [];
  late PrivateKey sk;
  late PublicKey pk;
  String walletAddr = "";
  String session = "";
  late Box sharedSecret;

  @override
  void initState() {
    super.initState();
    sk = PrivateKey.generate();
    pk = sk.publicKey;
  }

  void _connect() async {
    Uri url = Uri(
      scheme: 'https',
      host: 'phantom.app',
      path: '/ul/v1/connect',
      queryParameters: {
        'dapp_encryption_public_key': base58.encode(pk.asTypedList),
        'cluster': "devnet",
        'app_url': "https://phantom.app",
        'redirect_link': 'niftyclick://deeplink.connect',
      },
    );
    launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  _onConnect(Map params) async {
    sharedSecret = Box(
      myPrivateKey: sk,
      theirPublicKey: PublicKey(
        base58.decode(
          params["phantom_encryption_public_key"],
        ),
      ),
    );

    final decryptedData = sharedSecret.decrypt(
      ByteList(base58.decode(
        params["data"],
      )),
      nonce: base58.decode(params["nonce"]),
    );

    Map data = const JsonDecoder().convert(String.fromCharCodes(decryptedData));

    session = data["session"];
    walletAddr = data["public_key"];

    print(data);
    logs.add(
      Text(
        "Wallet address: ${data["public_key"].toString().substring(0, 16)}...",
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SelectImage(
            camera: widget.camera,
            publicKey: walletAddr,
          ),
        ),
        (route) => false,
      );
    });
  }

  void _disconnect() async {
    JsonEncoder encoder = const JsonEncoder();
    Map payload = {
      "session": session,
    };

    var nonce = PineNaClUtils.randombytes(24);

    final encryptedMsg = sharedSecret
        .encrypt(
          encoder.convert(payload).codeUnits.toUint8List(),
          nonce: nonce,
        )
        .cipherText;

    Uri url = Uri(
      scheme: 'https',
      host: 'phantom.app',
      path: '/ul/v1/disconnect',
      queryParameters: {
        'dapp_encryption_public_key': base58.encode(pk.asTypedList),
        'nonce': base58.encode(nonce.toUint8List()),
        'payload': base58.encode(encryptedMsg.toUint8List()),
        'redirect_link': 'niftyclick://deeplink.disconnect',
      },
    );
    launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    DeepLinkProvider provider = DeepLinkProvider();
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text("Flutter Phantom Deeplinking"),
            ),
            body: Provider<DeepLinkProvider>(
              create: (context) => provider,
              dispose: (context, provider) => provider.dispose(),
              child: StreamBuilder<String>(
                stream: provider.state,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Uri redirectedUri = Uri.parse(snapshot.data!);
                    Map params = redirectedUri.queryParameters;
                    if (params.containsKey("errorCode")) {
                      print(params["errorMessage"]);
                    } else {
                      switch (redirectedUri.host.split('.')[1]) {
                        case 'connect':
                          _onConnect(params);
                          break;
                        case 'disconnect':
                          print('disconnected');
                          break;
                        default:
                      }
                    }
                  }
                  return Center(
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 400,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "LOGS:",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                ...logs,
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _connect,
                          child: const Text("Connect Phantom"),
                        ),
                        ElevatedButton(
                          onPressed: () => walletAddr == ""
                              ? ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please connect wallet first",
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                )
                              : _disconnect(),
                          child: const Text("Disconnect"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )));
  }
}
