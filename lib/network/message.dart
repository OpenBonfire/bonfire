import 'dart:async';

import 'package:bonfire/globals.dart';
import 'package:nyxx/nyxx.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  final _eventController = StreamController<MessageCreateEvent>.broadcast();

  factory MessageService() {
    return _instance;
  }

  MessageService._internal();

  Stream<MessageCreateEvent> get eventStream => _eventController.stream;

  void initSubscription() {
    globalClient!.onMessageCreate.listen((event) async {
    _eventController.add(event);
    });
  }

  void dispose() {
    _eventController.close();
  }
}
