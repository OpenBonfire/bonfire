import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MFAPage extends StatefulWidget {
  const MFAPage({super.key});

  @override
  State<MFAPage> createState() => _MFAPageState();
}

class _MFAPageState extends State<MFAPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
          child: Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 22, 20, 20),
                  borderRadius: BorderRadius.all(Radius.circular(36))),
              width: 400,
              height: 400,
              child: const Center(child: Text("multi factor :D")))),
    );
  }
}
