import 'package:flutter/material.dart';

class ServerIcon extends StatelessWidget {
  const ServerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
            child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ))));
  }
}
