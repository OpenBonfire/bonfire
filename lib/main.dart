import 'package:bonfire/views/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyxx/nyxx.dart';
import 'dart:io';

void main() async {
  runApp(MaterialApp(home: ProviderScope(child: LoginPage())));
}