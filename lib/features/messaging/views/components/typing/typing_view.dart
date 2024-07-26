import 'package:bonfire/features/channels/repositories/typing.dart';
import 'package:firebridge/firebridge.dart' hide Builder;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TypingView extends ConsumerStatefulWidget {
  final Snowflake channelId;
  const TypingView({super.key, required this.channelId});

  @override
  ConsumerState<TypingView> createState() => _TypingViewState();
}

class _TypingViewState extends ConsumerState<TypingView> {
  @override
  Widget build(BuildContext context) {
    List<dynamic> typingOutput =
        ref.watch(typingProvider(widget.channelId)).value ?? [];
    return SizedBox(
        height: typingOutput.isNotEmpty ? 30 : 0,
        child: Builder(builder: (context) {
          if (typingOutput.isEmpty) {
            return Container();
          }

          List<Widget> children = typingOutput.map((e) {
            String? name;
            if (e is Member) {
              name = e.nick ?? e.user!.globalName ?? e.user!.username;
            } else if (e is User) {
              name = e.globalName ?? e.username;
            }

            String sep = ", ";
            if (typingOutput.length == 1) {
              sep = "";
            } else if (typingOutput.length == 2 ||
                typingOutput.indexOf(e) == typingOutput.length - 2) {
              sep = " and ";
            }

            if (typingOutput.indexOf(e) == typingOutput.length - 1) {
              sep = "";
            }

            return Padding(
              padding: const EdgeInsets.only(left: 1.75),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: name,
                      style: GoogleFonts.publicSans(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: sep,
                      style: GoogleFonts.publicSans(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList();

          children.insert(
              0,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white, size: 18),
              ));

          children.add(
            Padding(
              padding: const EdgeInsets.only(left: 1.75),
              child: Text(
                ' ${typingOutput.length == 1 ? 'is' : 'are'} typing...',
                style: GoogleFonts.publicSans(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          );

          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          );
        }));
  }
}
