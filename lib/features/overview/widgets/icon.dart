import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ServerIcon extends StatefulWidget {
  const ServerIcon({super.key});

  @override
  State<ServerIcon> createState() => ServerIconState();
}

class ServerIconState extends State<ServerIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
    );
  }
}
