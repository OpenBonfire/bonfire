import 'package:universal_platform/universal_platform.dart';

// /*
// TODO: Implement custom wrappers over UniversalPlatform, along with additions for smart watches
// We can use this to determine the orientation and such, which can give us tablet support too
// */

// class BonfirePlatform {
//   // static bool isDesktop = UniversalPlatform.isDesktop;
//   // static bool isWeb = UniversalPlatform.isWeb;
//   // static bool isMobile = UniversalPlatform.isMobile;
//   // static bool isMacOS = UniversalPlatform.isMacOS;
//   // static bool isWindows = UniversalPlatform.isWindows;
//   // static bool isLinux = UniversalPlatform.isLinux;
//   // static bool isFuchsia = UniversalPlatform.isFuchsia;
//   // static bool isAndroid = UniversalPlatform.isAndroid;
//   // static bool isIOS = UniversalPlatform.isIOS;
//   // static bool isDesktopOrWeb = UniversalPlatform.isDesktopOrWeb;
// }

import 'package:flutter/material.dart';

bool isSmartwatch(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  bool isSmallScreen = screenWidth < 250 && screenHeight < 250;

  bool isAndroid = UniversalPlatform.isAndroid;

  return isSmallScreen && isAndroid;
}
