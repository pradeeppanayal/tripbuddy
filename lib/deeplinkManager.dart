import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/widgets.dart';
import 'package:tripbuddyapp/beans.dart';
import 'package:tripbuddyapp/helpers/groupActionhelper.dart';

/**
 * @author Pradeep CH
 */

class DeepLinkHandler {
  static Future<String> prepareLink(Group group) async {
    String url =
        "https://holdhand.tripbuddy/join/${group.groupId}/${group.passCode}";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://tripbuddyapp.page.link',
      link: Uri.parse(url),
      androidParameters: AndroidParameters(
        packageName: 'com.holdhand.tripbuddyapp',
        minimumVersion: 0,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.holdhand.tripbuddyapp',
        minimumVersion: '1.0.1',
      ),
    );

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri surl = shortLink.shortUrl;
    return surl.toString();
  }

  static void handleAndRedirect(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        _processLink(deepLink.path, context);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  static void _processLink(String path, BuildContext context) {
    print("Processing link $path");
    List<String> parts = path.split("/");
    parts.retainWhere((element) => element.isNotEmpty);
    print(parts);
    if (parts.length == 1) {
      Navigator.pushNamed(context, parts[0]);
      return;
    }
    switch (parts[0]) {
      case 'join':
        final Group group = Group();
        group.groupId = parts[1];
        group.passCode = parts.length > 2 ? parts[2] : "";
        GroupActionHelper.joinAndRedirect(group, context);
        break;
    }
  }
}
