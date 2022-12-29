import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nifty_click_app/constants.dart';
import 'package:photo_manager/photo_manager.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightSilver,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0,
        backgroundColor: lightSilver,
        title: const Text(
          "Gallery",
          style: TextStyle(
            fontSize: 32,
            color: darkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<File>>(
        future: () async {
          List<File> galleryPhotos = [];
          final PermissionState ps =
              await PhotoManager.requestPermissionExtend();
          if (ps.isAuth) {
            final List<AssetPathEntity> paths =
                await PhotoManager.getAssetPathList();
            if (Platform.isIOS) {
              AssetPathEntity path =
                  paths.firstWhere((path) => path.name == "Recents");
              List<AssetEntity> photos =
                  await path.getAssetListRange(start: 0, end: 35);
              for (var photo in photos) {
                String mime = await photo.mimeTypeAsync ?? "";
                print(mime);
                File? file = await photo.loadFile();
                if (file != null) galleryPhotos.add(file);
              }
            }
          }

          return galleryPhotos;
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Wrap(
              children: snapshot.data!
                  .map(
                    (file) => Image.file(
                      file,
                      width: 50,
                    ),
                  )
                  .toList(),
            );
          }
        },
      ),
    );
  }
}
