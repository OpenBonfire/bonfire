import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/shared/models/message.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_viewer/markdown_viewer.dart';

class MessageView extends ConsumerStatefulWidget {
  const MessageView({super.key});

  @override
  ConsumerState<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<MessageView> {
  @override
  Widget build(BuildContext context) {
    var messageOutput = ref.watch(messagesProvider);
    var messages = messageOutput.valueOrNull ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.foreground,
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, -1),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: messages.length,
        reverse: true,
        itemBuilder: (context, index) {
          return MessageBox(message: messages[index]);
        },
      ),
    );
  }
}

class MessageBox extends StatefulWidget {
  final BonfireMessage message;
  MessageBox({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

Map<int, Widget> messageWidgets = Map<int, Widget>();

class _MessageBoxState extends State<MessageBox>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String dateTimeFormat(DateTime time) {
    String section1;
    String section2;

    if (time.day == DateTime.now().day) {
      section1 = 'Today';
    } else if (time.day == DateTime.now().day - 1) {
      section1 = 'Yesterday';
    } else {
      section1 = '${time.day}/${time.month}/${time.year}';
    }

    var twelveHour = time.hour > 12 ? time.hour - 12 : time.hour;
    var section3 = time.hour > 12 ? 'PM' : 'AM';

    section2 = ' at $twelveHour:${time.minute} $section3';

    return section1 + section2;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return OutlinedButton(
      style: ButtonStyle(
        alignment: Alignment.centerLeft,
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        side: MaterialStateProperty.all<BorderSide>(
          const BorderSide(
            width: 0,
            color: Color.fromARGB(0, 77, 77, 77),
          ),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Theme.of(context).custom.colorTheme.foreground;
            }
            return Colors.transparent;
          },
        ),
      ),
      onPressed: () {
        print("message pressed");
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.message.member.icon != null)
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child:
                              Image(image: widget.message.member.icon!.image)),
                    ))
                : const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                    ),
                  ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width - 120,
                  child: Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 6, top: 0),
                          child: Text(
                            widget.message.member.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 6, top: 0),
                        child: Text(
                          dateTimeFormat(widget.message.timestamp.toLocal()),
                          textAlign: TextAlign.left,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            color: Color.fromARGB(189, 255, 255, 255),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 0),
                  child: SizedBox(
                    width: 300,
                    // width: MediaQuery.of(context).size.width -
                    //     ((Platform.isAndroid | Platform.isIOS) ? 120 : 500),
                    child: MarkdownViewer(
                      widget.message.content,
                      enableTaskList: true,
                      enableSuperscript: false,
                      enableSubscript: false,
                      enableFootnote: false,
                      enableImageSize: false,
                      enableKbd: false,
                      syntaxExtensions: const [],
                      elementBuilders: const [],
                      styleSheet: MarkdownStyle(
                          paragraph:
                              Theme.of(context).custom.textTheme.bodyText1),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
