import 'package:flutter/material.dart';

@immutable
class BonfireThemeExtension extends ThemeExtension<BonfireThemeExtension> {
  static BonfireThemeExtension of(BuildContext context) =>
      Theme.of(context).extension<BonfireThemeExtension>()!;

  const BonfireThemeExtension({
    required this.foreground,
    required this.background,
    required this.dirtyWhite,
    required this.gray,
    required this.darkGray,
    required this.primary,
    required this.red,
    required this.green,
    required this.yellow,
    // required this.bodyMedium!,
    // required this.bodyText2,
    // required this.caption,
    // required this.bold,
    // required this.titleLarge,
    // required this.titleLargeBold,
    // required this.titleMedium,
    // required this.titleSmall,
    // required this.subtitle1,
    // required this.subtitle2,
    // required this.subtitle3,
  });

  final Color foreground;
  final Color background;
  final Color dirtyWhite;
  final Color gray;
  final Color darkGray;
  final Color primary;
  final Color red;
  final Color green;
  final Color yellow;

  // final TextTheme bodyText1;
  // final TextTheme bodyText2;
  // final TextTheme caption;
  // final TextTheme bold;
  // final TextTheme titleLarge;
  // final TextTheme titleLargeBold;
  // final TextTheme titleMedium;
  // final TextTheme titleSmall;
  // final TextTheme subtitle1;
  // final TextTheme subtitle2;
  // final TextTheme subtitle3;

  @override
  ThemeExtension<BonfireThemeExtension> copyWith() {
    // TODO: implement copyWith
    throw UnimplementedError();
  }

  @override
  ThemeExtension<BonfireThemeExtension> lerp(
      covariant ThemeExtension<BonfireThemeExtension>? other, double t) {
    // TODO: implement lerp
    throw UnimplementedError();
  }
}
