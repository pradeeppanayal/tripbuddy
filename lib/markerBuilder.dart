import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as Images;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/*
 *  @author Pradeep CH
 */
class MarkerBuilder {
  static final Map<String, BitmapDescriptor> cachedIcons = new Map();
  static Future<BitmapDescriptor> makeReceiptImage(
      String url, String uid, BuildContext context) async {
    if (cachedIcons.containsKey(uid)) return cachedIcons[uid];
    if (url == null) {
      return BitmapDescriptor.defaultMarker;
    }

    final File avatharImageFile =
        await DefaultCacheManager().getSingleFile(url);
    Uint8List avtarimageData = await avatharImageFile.readAsBytes();
    List<int> avatarImagebytes = Uint8List.view(avtarimageData.buffer);
    Images.Image avatarImage = Images.decodeImage(avatarImagebytes);

    int targetWidth = (getMarkerSize(context) * 1.2).toInt();
    ByteData imageData = await rootBundle.load('assets/images/ma.png');
    Uint8List bytes = Uint8List.view(imageData.buffer);
    Images.Image markerImage = Images.decodeImage(bytes);
    int marginPadding = ((targetWidth / 70) * 2 + 2).toInt();
    //resize pointer based on the pixal
    markerImage = Images.copyResize(markerImage, width: targetWidth);

    //resize the avatar image to fit inside the marker image
    avatarImage = Images.copyResize(avatarImage,
        width: markerImage.width ~/ 1.1, height: markerImage.height ~/ 1.4);

    int radius = avatarImage.width ~/ 2;
    int originX = avatarImage.width ~/ 2, originY = avatarImage.height ~/ 2;
    //print(markerImage.width);
    //draw the avatar image cropped as a circle inside the marker image
    for (int y = -radius; y <= radius; y++)
      for (int x = -radius; x <= radius; x++)
        if (x * x + y * y <= radius * radius)
          markerImage.setPixelSafe(
              originX + x + marginPadding,
              originY + y + 2 + marginPadding,
              avatarImage.getPixelSafe(originX + x, originY + y));

    // print("${markerImage.width}${markerImage.length}");
    BitmapDescriptor desc =
        BitmapDescriptor.fromBytes(Images.encodePng(markerImage));
    cachedIcons[uid] = desc;
    return desc;
  }

  static int getMarkerSize(BuildContext context) {
    MediaQueryData data = MediaQuery.of(context);
    double pixelRatio = data.devicePixelRatio;
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    //print("========================================$pixelRatio$isIOS");
    int size = 70;

    if (!isIOS) {
      if (pixelRatio >= 3.5) {
        size = 210;
      } else if (pixelRatio >= 2.5) {
        size = 140;
      } else if (pixelRatio >= 1.5) {
        size = 70;
      } else {
        size = 35;
      }
    }
    return size;
  }

  static Future<BitmapDescriptor> getMarkerImageFromUrl(
    String url,
    String uid,
    BuildContext context, {
    int targetWidth,
  }) async {
    if (cachedIcons.containsKey(uid)) return cachedIcons[uid];
    if (url == null) {
      return BitmapDescriptor.defaultMarker;
    }

    final File markerImageFile = await DefaultCacheManager().getSingleFile(url);
    //TODO avoid using cache manager

    Uint8List markerImageBytes = await markerImageFile.readAsBytes();

    int targetWidth = getMarkerSize(context);
    //if (targetWidth != null) {
    markerImageBytes = await _resizeImageBytes(
      markerImageBytes,
      targetWidth,
    );
    //}

    BitmapDescriptor desc = BitmapDescriptor.fromBytes(markerImageBytes);
    cachedIcons[uid] = desc;
    return desc;
  }

  static Future<Uint8List> _resizeImageBytes(
    Uint8List imageBytes,
    int targetWidth,
  ) async {
    assert(imageBytes != null);
    assert(targetWidth != null);

    final Codec imageCodec = await instantiateImageCodec(
      imageBytes,
      targetWidth: targetWidth,
    );

    final FrameInfo frameInfo = await imageCodec.getNextFrame();

    final ByteData byteData = await frameInfo.image.toByteData(
      format: ImageByteFormat.png,
    );

    return byteData.buffer.asUint8List();
  }
}
