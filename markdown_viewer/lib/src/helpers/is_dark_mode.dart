import 'package:flutter/material.dart';

bool isDarkMode(BuildContext? context) =>
    context == null ? false : Theme.of(context).brightness == Brightness.dark;
