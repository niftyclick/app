import 'package:flutter/material.dart';
import 'package:nifty_click_app/screens/nft_gallery.dart';
import 'package:nifty_click_app/shared_prefs.dart';
import 'package:nifty_click_app/widgets/dashboard_header.dart';
import 'package:nifty_click_app/widgets/dashboard_help.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pinenacl/x25519.dart';

class Dashboard extends StatefulWidget {
  final String publicKey;
  final PublicKey dappKey;
  final Box sharedSecret;
  final String session;

  const Dashboard({
    Key? key,
    required this.publicKey,
    required this.dappKey,
    required this.sharedSecret,
    required this.session,
  }) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    PhotoManager.requestPermissionExtend();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color.fromRGBO(128, 128, 128, 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        "${widget.publicKey.substring(0, 3)}...${widget.publicKey.substring(widget.publicKey.length - 3)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DashboardHeader(
                publicKey: widget.publicKey,
                dappKey: widget.dappKey,
                sharedSecret: widget.sharedSecret,
                session: widget.session,
              ),
              if (SharedPrefs.getFirstOpen() == null) const DashboardHelp(),
              if (SharedPrefs.getFirstOpen() != null &&
                  SharedPrefs.getFirstOpen() == false) ...[
                const Text(
                  "NFT Gallery",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                NFTGallery(
                  publicKey: widget.publicKey,
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
