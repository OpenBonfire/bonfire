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
  double screenWidth = MediaQuery.sizeOf(context).width;
  double screenHeight = MediaQuery.sizeOf(context).height;
  bool isSmallScreen = screenWidth < 250 && screenHeight < 250;

  bool isAndroid = UniversalPlatform.isAndroid;

  return isSmallScreen && isAndroid;
}

bool shouldUseDesktopLayout(BuildContext context) {
  double screenWidth = MediaQuery.sizeOf(context).width;
  double screenHeight = MediaQuery.sizeOf(context).height;
  bool isLargeScreen = screenWidth > 1000 && screenHeight > 1000;

  bool isLandscape = screenWidth > screenHeight;

  bool isDesktop = UniversalPlatform.isDesktop;

  // temporary solution to support postmarketos / etc on mobile
  bool isLinux = UniversalPlatform.isLinux;

  return isLargeScreen || (isDesktop && !isLinux) || isLandscape;
}

bool shouldUseMobileLayout(BuildContext context) {
  return !shouldUseDesktopLayout(context);
}
