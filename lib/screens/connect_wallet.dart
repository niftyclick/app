import 'dart:convert';

import 'package:bs58/bs58.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nifty_click_app/screens/dashboard.dart';
import 'package:pinenacl/x25519.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../deep_link_provider.dart';
import 'package:nifty_click_app/constants.dart';

class ConnectWallet extends StatefulWidget {
  const ConnectWallet({
    Key? key,
  }) : super(key: key);

  @override
  State<ConnectWallet> createState() => _ConnectWalletState();
}

class _ConnectWalletState extends State<ConnectWallet> {
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

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Dashboard(
            publicKey: walletAddr,
          ),
        ),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    DeepLinkProvider provider = DeepLinkProvider();
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Image.asset(
              "images/home_screen_bg.png",
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Provider<DeepLinkProvider>(
              create: (context) => provider,
              dispose: (context, provider) => provider.dispose(),
              child: StreamBuilder<String>(
                stream: provider.state,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Uri redirectedUri = Uri.parse(snapshot.data!);
                    Map params = redirectedUri.queryParameters;
                    if (params.containsKey("errorCode")) {
                      if (kDebugMode) {
                        print(params["errorMessage"]);
                      }
                    } else {
                      switch (redirectedUri.host.split('.')[1]) {
                        case 'connect':
                          _onConnect(params);
                          break;
                      }
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset("images/logo.svg"),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 12, 0, 5),
                          child: Text(
                            "Welcome to",
                            style: TextStyle(
                              color: white,
                              fontWeight: FontWeight.w700,
                              fontSize: 40,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Text(
                          "NiftyClick",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: white,
                            fontSize: 46,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 50),
                          child: Text(
                            "Mint images as NFT on solana blockchain from your mobile phone",
                            style: TextStyle(
                              color: lightSilver,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shadowColor: Colors.black,
                            fixedSize: const Size.fromWidth(double.maxFinite),
                          ),
                          onPressed: _connect,
                          child: const Text(
                            "Connect Phantom Wallet",
                            style: TextStyle(
                              color: black,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 18, top: 50),
                          child: Text(
                            "© NiftyClick 2023.\nAll rights reserved.",
                            style: TextStyle(
                              color: Color.fromRGBO(119, 119, 119, 1),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/**
 * void _disconnect() async {
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
 */