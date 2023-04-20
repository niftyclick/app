import 'dart:convert';

import 'package:bs58/bs58.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nifty_click_app/screens/dashboard.dart';
import 'package:pinenacl/x25519.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

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
            dappKey: pk,
            sharedSecret: sharedSecret,
            session: session,
          ),
        ),
        (route) => false,
      );
    });
  }

  _onMinted(Map params) async {
    final decryptedData = sharedSecret.decrypt(
      ByteList(base58.decode(
        params["data"],
      )),
      nonce: base58.decode(params["nonce"]),
    );
    print("MINTED");

    // Map data = const JsonDecoder().convert(String.fromCharCodes(decryptedData));

    // session = data["session"];
    // walletAddr = data["public_key"];

    // Future.delayed(const Duration(seconds: 2), () {
    //   Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(
    //       builder: (context) => Dashboard(
    //         publicKey: walletAddr,
    //         dappKey: pk,
    //       ),
    //     ),
    //     (route) => false,
    //   );
    // });
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
                        print("ERROR: ${params["errorMessage"]}");
                      }
                    } else {
                      print(redirectedUri.host.split('.')[1]);
                      switch (redirectedUri.host.split('.')[1]) {
                        case 'connect':
                          _onConnect(params);
                          break;
                        case 'onSignAndSendTransaction':
                          _onMinted(params);
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

  // void _disconnect(String txn) async {
  //   JsonEncoder encoder = const JsonEncoder();
  //   Map payload = {
  //     "session": session,
  //     "transaction":
  //         "A6JBnWJ8HyWpy8IE5dqIBG+/sSrUQrm9XorpjutuHvz1Jl/vAMMcX9paam1Mm/C6ZckFGzjNA3E1GY+HWCLF1gI2ikWjWqXn3dIIZNc2zjqXVVT7a2TGdrEqySQPFYYFZyG93sDKll2UwHEfps67SSWgIChFdzeOIQs/oNmMvIYPAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMABg0IrGLdb0FvHanWE+e0eyL2S2D1UizLDQuwAf7HpoQlg7sU8c3u4MTcn0iSM+zq8c5iioJDmOwYkOkLdKUcGEcYBqAu/cKwAfcsN4pS0ah54KmMoGqttw793qTES3Wcdvs4Tdh4uq3y51zXIJJVm5uJABSMxCLdEnN7jhJq82yOAlD+Ak48umXCv4jGO8/Cx+MPvY1SoHf6VcWxFx0qnyXOX07dipfFQ5BUphuDpaaSUzQmVxpIiJouQgnLXAWqwgHED6SHEB7oQX2XckkAd4JLuBVzjRZdvBndRCW4mGkc0gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAjJclj04kifG7PRApFI4NgwtaE5na/xCEBI572Nvp+FkIr/iUw/pnwBY6MPI0oz00Z/A6oWQXMV60uBQnvZum7QtwZbHj0XxFOJ1Sf2sEw81YuGxzGqD9tUm20bwD+ClGBqfVFxh70WY12tQEVf3CwMEkxo8hVnWl27rLXwgAAAAG3fbh12Whk9nL4UbO63msHLSF7V9bN5E6jPWFfv8AqW4fXR4t5tmiP6QMm5luycW4E0HMXtzjuxULIPsJCV76AwcCAgAMAgAAAAAtMQEAAAAACgkGBAEAAAAHCwzBASoABwAAAGV4YW1wbGUDAAAATEZHdQAAAGh0dHBzOi8vYXgyZzZubXdnbnU2aGdodHd3cmZ0NHB3bjNlbnI1aWt2cDRtcHluNmR6NmZxMmhlNGRyZy5hcndlYXZlLm5ldC9CZlJWTlpZWmFAMFk4N1dpV8KjSDJic2lZOTBxci1NZmh2aDU4V0dpazQwTQEAAQEAAAAIrGLdb0FvHanWE+e0eyL2S2D1UizLDQuwAf7HpoQlgwFkAAEAAAAAAAEAAQAKDwMCBgQFAQAKAAcLDAgJCgsrAAEAAAAAAAAAAA==",
  //   };

  //   var nonce = PineNaClUtils.randombytes(24);

  //   final encryptedMsg = sharedSecret
  //       .encrypt(
  //         encoder.convert(payload).codeUnits.toUint8List(),
  //         nonce: nonce,
  //       )
  //       .cipherText;

  //   Uri url = Uri(
  //     scheme: 'https',
  //     host: 'phantom.app',
  //     path: '/ul/v1/signAndSendTransaction',
  //     queryParameters: {
  //       'dapp_encryption_public_key': base58.encode(pk.asTypedList),
  //       'nonce': base58.encode(nonce),
  //       'payload': base58.encode(encryptedMsg.toUint8List()),
  //       'redirect_link': 'niftyclick://deeplink.onSignAndSendTransaction',
  //     },
  //   );
  //   launchUrl(
  //     url,
  //     mode: LaunchMode.externalApplication,
  //   );
  // }
}
