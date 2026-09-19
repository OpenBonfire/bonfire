import 'package:flutter/material.dart';

import 'package:dave/dave.dart' as dave;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('dave (libdave FFI bindings)')),
        body: Center(
          child: Text(
            'daveMaxSupportedProtocolVersion() = ${dave.daveMaxSupportedProtocolVersion()}',
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
