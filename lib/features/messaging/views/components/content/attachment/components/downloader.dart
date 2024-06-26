import 'dart:typed_data';

import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:file_icon/file_icon.dart';
import 'package:internet_file/internet_file.dart';
import 'package:file_selector/file_selector.dart';

class DownloadAttachment extends StatefulWidget {
  final Attachment attachment;
  const DownloadAttachment({super.key, required this.attachment});

  @override
  State<DownloadAttachment> createState() => _DownloadAttachmentState();
}

class _DownloadAttachmentState extends State<DownloadAttachment> {
  double downloadPercentage = 0;
  double opacity = 1;

  Future<void> saveBytesAsFile(
      Uint8List bytes, FileSaveLocation location) async {
    String mimeType = widget.attachment.contentType ?? 'text/plain';
    final XFile textFile = XFile.fromData(bytes,
        mimeType: mimeType, name: widget.attachment.fileName);
    await textFile.saveTo(location.path);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 60,
        width: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).custom.colorTheme.embedBackground,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  FileIcon(
                    widget.attachment.fileName,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.attachment.fileName,
                    style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    color: Colors.white,
                    onPressed: () async {
                      final FileSaveLocation? result = await getSaveLocation(
                          suggestedName: widget.attachment.fileName);
                      if (result == null) return;
                      final Uint8List bytes = await InternetFile.get(
                        widget.attachment.url.toString(),
                        progress: (receivedLength, contentLength) async {
                          setState(() {
                            downloadPercentage = receivedLength / contentLength;
                          });
                          // tween opacity from 1 to 0
                          await Future.delayed(const Duration(seconds: 2));
                          if (downloadPercentage == 1) {
                            for (var i = 0; i < 100; i++) {
                              await Future.delayed(
                                  const Duration(milliseconds: 5));
                              setState(() {
                                opacity = 1 - i / 100;
                              });
                            }
                          }
                        },
                      );

                      saveBytesAsFile(bytes, result);
                    },
                    icon: const Icon(Icons.download),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                  width: 300 * downloadPercentage,
                  height: 8,
                  decoration: BoxDecoration(
                      color: Theme.of(context)
                          .custom
                          .colorTheme
                          .blurple
                          .withOpacity(opacity)
                      // borderRadius: BorderRadius.circular(12),
                      )),
            )
          ],
        ),
      ),
    );
  }
}
