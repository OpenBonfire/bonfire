import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/theme/color_theme.dart';
import 'package:bonfire/theme/text_theme.dart';

ColorTheme darkTheme = ColorTheme(
  background: AppColorsDark.background,
  foreground: AppColorsDark.foreground,
  selectedChannelText: AppColorsDark.selectedChannelText,
  deselectedChannelText: AppColorsDark.deselectedChannelText,
  channelCategory: AppColorsDark.channelCategory,
  channelListBackground: AppColorsDark.channelListBackground,
  navbarIconSelected: AppColorsDark.navbarIconSelected,
  navbarIconDeselected: AppColorsDark.navbarIconDeselected,
  serverOverviewSubtext: AppColorsDark.serverOverviewSubtext,
  selectedChannel: AppColorsDark.selectedChannel,
  channelHeaderText: AppColorsDark.channelHeaderText,
  button1: AppColorsDark.button1,
  buttonIcon1: AppColorsDark.buttonIcon1,
  navbarBackground: AppColorsDark.navbarBackground,
  messageBar: AppColorsDark.messageBar,
  messageBarBackground: AppColorsDark.messageBarBackground,
  messageBarHintText: AppColorsDark.messageBarHintText,
  messageBarEmbeddedIcon: AppColorsDark.messageBarEmbeddedIcon,
  messageBarActivatedIcon: AppColorsDark.messageBarActivatedIcon,
  messageBarDeactivatedIcon: AppColorsDark.messageBarDeactivatedIcon,
  messageViewBackground: AppColorsDark.messageViewBackground,
  darkButtonBackground: AppColorsDark.darkButtonBackground,
  messageStatusBarText: AppColorsDark.messageStatusBarText,
  embedBackground: AppColorsDark.embedBackground,
  messageHighlight: AppColorsDark.messageHighlight,
  floatingActionColorButton: AppColorsDark.floatingActionColorButton,
  blurple: AppColorsDark.blurple,
  red: AppColorsDark.red,
  green: AppColorsDark.green,
  yellow: AppColorsDark.yellow,
);

class CustomThemeData {
  final textTheme = CustomTextTheme();
  late final ColorTheme colorTheme;

  CustomThemeData({required bool isDarkTheme}) {
    colorTheme = isDarkTheme ? darkTheme : darkTheme;
  }
}

final darkThemeProvider = Provider((ref) => _darkTheme);
// final lightThemeProvider = Provider((ref) => _theme);

final _customTheme = CustomThemeData(isDarkTheme: false);

// Dark theme
final _customDarkTheme = CustomThemeData(isDarkTheme: true);
final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(4.0),
    ),
    backgroundColor: AppColorsDark.background,
    titleTextStyle: const TextStyle(
      color: AppColorsDark.selectedChannelText,
      fontSize: 16,
    ),
    contentTextStyle: const TextStyle(
      color: AppColorsDark.selectedChannelText,
      fontSize: 16,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColorsDark.blurple,
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: AppColorsDark.background,
  iconTheme: const IconThemeData(
    color: AppColorsDark.buttonIcon1,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColorsDark.green,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColorsDark.foreground,
    thickness: 0.1,
  ),
);

extension CustomTheme on ThemeData {
  CustomThemeData get custom =>
      brightness == Brightness.dark ? _customDarkTheme : _customTheme;

  AssetImage themedImage(String name) {
    final path =
        brightness == Brightness.dark ? 'assets/images/dark' : 'assets/images';
    return AssetImage('$path/$name');
  }
}
