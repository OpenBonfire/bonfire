import 'package:flutter/material.dart';
import 'package:flutter_webrtc_rs/flutter_webrtc_rs.dart';

import 'loopback_demo.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoopbackDemoPage());
  }
}

/// See [runLoopbackDemo] (`loopback_demo.dart`) for what this actually exercises.
class LoopbackDemoPage extends StatefulWidget {
  const LoopbackDemoPage({super.key});

  @override
  State<LoopbackDemoPage> createState() => _LoopbackDemoPageState();
}

class _LoopbackDemoPageState extends State<LoopbackDemoPage> {
  final _log = <String>[];
  bool _running = false;

  void _addLog(String line) {
    if (!mounted) return;
    setState(() => _log.add(line));
  }

  Future<void> _runLoopback() async {
    setState(() {
      _running = true;
      _log.clear();
    });
    try {
      await runLoopbackDemo(_addLog);
      _addLog('✅ done');
    } catch (e, st) {
      _addLog('❌ error: $e');
      _addLog(st.toString());
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_webrtc_rs loopback demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: _running ? null : _runLoopback,
              child: Text(_running ? 'Running…' : 'Run loopback demo'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _log.length,
              itemBuilder: (context, i) => Text(
                _log[i],
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
