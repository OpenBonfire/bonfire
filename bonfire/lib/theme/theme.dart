import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/theme/color_theme.dart';
import 'package:bonfire/theme/text_theme.dart';

/// Which theme is active.
enum ThemeType { dark, amoled }

/// ThemeExtension to attach ColorTheme.
@immutable
class ColorThemeExtension extends ThemeExtension<ColorThemeExtension> {
  final ColorTheme colorTheme;
  const ColorThemeExtension(this.colorTheme);

  @override
  ColorThemeExtension copyWith({ColorTheme? colorTheme}) {
    return ColorThemeExtension(colorTheme ?? this.colorTheme);
  }

  @override
  ColorThemeExtension lerp(
      ThemeExtension<ColorThemeExtension>? other, double t) {
    if (other is! ColorThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}

/// ThemeExtension to attach CustomTextTheme.
@immutable
class TextThemeExtension extends ThemeExtension<TextThemeExtension> {
  final CustomTextTheme textTheme;
  const TextThemeExtension(this.textTheme);

  @override
  TextThemeExtension copyWith({CustomTextTheme? textTheme}) {
    return TextThemeExtension(textTheme ?? this.textTheme);
  }

  @override
  TextThemeExtension lerp(ThemeExtension<TextThemeExtension>? other, double t) {
    if (other is! TextThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}

final _darkColorTheme = ColorTheme(
  background: AppColorsDark.background,
  foreground: AppColorsDark.foreground,
  dirtyWhite: AppColorsDark.dirtyWhite,
  gray: AppColorsDark.gray,
  darkGray: AppColorsDark.darkGray,
  primary: AppColorsDark.primary,
  red: AppColorsDark.red,
  green: AppColorsDark.green,
  yellow: AppColorsDark.yellow,
);

final _amoledColorTheme = ColorTheme(
  background: AppColorsAmoled.background,
  foreground: AppColorsAmoled.foreground,
  dirtyWhite: AppColorsAmoled.dirtyWhite,
  gray: AppColorsAmoled.gray,
  darkGray: AppColorsAmoled.darkGray,
  primary: AppColorsAmoled.primary,
  red: AppColorsAmoled.red,
  green: AppColorsAmoled.green,
  yellow: AppColorsAmoled.yellow,
);

final _colorDarkExtension = ColorThemeExtension(_darkColorTheme);
final _colorAmoledExtension = ColorThemeExtension(_amoledColorTheme);
final _textExtension = TextThemeExtension(CustomTextTheme());

final ThemeData _darkTheme = ThemeData.dark().copyWith(
  extensions: <ThemeExtension<dynamic>>[
    _colorDarkExtension,
    _textExtension,
  ],
  dialogTheme: DialogThemeData(
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(4.0),
    ),
    backgroundColor: AppColorsDark.background,
    titleTextStyle: const TextStyle(
      color: AppColorsDark.dirtyWhite,
      fontSize: 16,
    ),
    contentTextStyle: const TextStyle(
      color: AppColorsDark.dirtyWhite,
      fontSize: 16,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColorsDark.primary,
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: AppColorsDark.background,
  iconTheme: const IconThemeData(
    color: AppColorsDark.dirtyWhite,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColorsDark.green,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColorsDark.foreground,
    thickness: 0.1,
  ),
);

final ThemeData _amoledTheme = ThemeData.dark().copyWith(
  extensions: <ThemeExtension<dynamic>>[
    _colorAmoledExtension,
    _textExtension,
  ],
  dialogTheme: DialogThemeData(
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(4.0),
    ),
    backgroundColor: AppColorsAmoled.background,
    titleTextStyle: const TextStyle(
      color: AppColorsAmoled.dirtyWhite,
      fontSize: 16,
    ),
    contentTextStyle: const TextStyle(
      color: AppColorsAmoled.dirtyWhite,
      fontSize: 16,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColorsAmoled.primary,
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: AppColorsAmoled.background,
  iconTheme: const IconThemeData(
    color: AppColorsAmoled.dirtyWhite,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColorsAmoled.green,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColorsAmoled.foreground,
    thickness: 0.1,
  ),
);

final themeTypeProvider = StateProvider<ThemeType>((_) => ThemeType.amoled);

final themeDataProvider = Provider<ThemeData>((ref) {
  final type = ref.watch(themeTypeProvider);
  return type == ThemeType.amoled ? _amoledTheme : _darkTheme;
});

class _CustomTheme {
  final ColorTheme colorTheme;
  final CustomTextTheme textTheme;
  final ThemeData _themeData;

  _CustomTheme(this._themeData)
      : colorTheme = _themeData.extension<ColorThemeExtension>()!.colorTheme,
        textTheme = _themeData.extension<TextThemeExtension>()!.textTheme;

  AssetImage themedImage(String name) {
    final folder = colorTheme.background == AppColorsAmoled.background
        ? 'assets/images/dark'
        : 'assets/images';
    return AssetImage('$folder/$name');
  }
}

/// Extension on ThemeData to get our custom themes.
extension CustomThemeX on ThemeData {
  _CustomTheme get custom => _CustomTheme(this);
}
