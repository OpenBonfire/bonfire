import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:opus/opus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 20);

    final encoder = OpusEncoder(sampleRate: 48000, channels: 1);
    final packet = encoder.encode(List.filled(960, 0).toInt16List(), frameSize: 960);
    encoder.dispose();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('opus (libopus FFI bindings)')),
        body: Center(
          child: Text(
            'Encoded a 960-sample silent frame to ${packet.length} Opus bytes',
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

extension on List<int> {
  Int16List toInt16List() => Int16List.fromList(this);
}
