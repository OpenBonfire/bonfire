import 'package:firebridge/src/utils/is_web_web.dart'
    if (dart.library.io) 'package:firebridge/src/utils/is_web_io.dart';
import 'package:http/http.dart';

import 'package:firebridge/src/client.dart';
import 'package:firebridge/src/http/request.dart';

/// A request to Discord's CDN.
class CdnRequest extends HttpRequest {
  /// Create a new [CdnRequest].
  CdnRequest(super.route, {super.queryParameters})
      : super(method: 'GET', authenticated: false, applyGlobalRateLimit: false);

  @override
  BaseRequest prepare(Nyxx client) {
    return Request(method, Uri.https(client.apiOptions.cdnHost, route.path));
  }
}
