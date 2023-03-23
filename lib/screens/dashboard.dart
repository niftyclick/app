import 'package:flutter/material.dart';
import 'package:nifty_click_app/widgets/dashboard_header.dart';
import 'package:nifty_click_app/widgets/dashboard_help.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:camera/camera.dart';

class Dashboard extends StatefulWidget {
  final List<CameraDescription> camera;
  final String publicKey;

  const Dashboard({
    Key? key,
    required this.camera,
    required this.publicKey,
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
              DashboardHeader(publicKey: widget.publicKey),
              const DashboardHelp(),
            ],
          ),
        ),
      ),
    );
  }
}
