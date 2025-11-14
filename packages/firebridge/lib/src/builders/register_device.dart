import 'package:firebridge/src/builders/builder.dart';
import 'package:firebridge/src/models/user/notification.dart';

class PushSyncTokenBuilder extends CreateBuilder<PushSyncToken> {
  String token;

  PushSyncTokenBuilder({
    required this.token,
  });

  @override
  Map<String, Object?> build() => {
        'token': token,
      };
}
