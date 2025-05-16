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
