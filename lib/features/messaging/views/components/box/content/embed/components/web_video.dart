import 'dart:math';

import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fireview/webview_all.dart';

class WebVideo extends ConsumerStatefulWidget {
  final Embed embed;
  const WebVideo({super.key, required this.embed});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WebVideoState();
}

class _WebVideoState extends ConsumerState<WebVideo> {
  bool _isPlaying = false;
  double height = 200;

  Widget embedWidget() {
    return _isPlaying
        ? SizedBox(
            width: min(
                min(widget.embed.thumbnail!.width!.toDouble(),
                    MediaQuery.of(context).size.width - 90),
                500),
            height: height,
            child: Webview(
              url: widget.embed.video!.url!.toString(),
            ))
        : OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              side: const BorderSide(
                color: Color.fromARGB(0, 255, 255, 255),
                width: 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            onPressed: () {
              setState(() {
                _isPlaying = true;
                // force a second state update
                // pretty ugly solution, but reliable
                // this is actually a fireview issue
                Future.delayed(const Duration(milliseconds: 200), () {
                  setState(() {
                    _isPlaying = true;
                  });
                });
              });
            },
            child: Image.network(widget.embed.thumbnail!.url.toString(),
                fit: BoxFit.cover),
          );
  }

  @override
  Widget build(BuildContext context) {
    var aspect = widget.embed.thumbnail!.width!.toDouble() /
        widget.embed.thumbnail!.height!.toDouble();
    double width = min(
        min(widget.embed.thumbnail!.width!.toDouble(),
            MediaQuery.of(context).size.width - 90),
        500);

    height = width / aspect;

    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.red,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).custom.colorTheme.embedBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            widget.embed.provider?.name ?? "Provider not found",
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .custom
                                .textTheme
                                .bodyText2
                                .copyWith(
                                    color: const Color.fromARGB(
                                        255, 172, 172, 172),
                                    fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(widget.embed.title ?? "Title not found",
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .custom
                                .textTheme
                                .bodyText2
                                .copyWith(fontSize: 14)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: width.toDouble(),
                    child: embedWidget(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
