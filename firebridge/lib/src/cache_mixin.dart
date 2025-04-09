import 'dart:async';
import 'package:firebridge/src/client.dart';

extension CacheMixin on Nyxx {
  static final Expando<StreamController<Object?>>
      _cacheUpdateControllerExpando = Expando<StreamController<Object?>>();

  /// Gets the single StreamController for cache events for this client instance.
  StreamController<Object?> _getOrCreateCacheUpdateController() {
    var controller = _cacheUpdateControllerExpando[this];
    if (controller == null) {
      controller = StreamController<Object?>.broadcast();
      _cacheUpdateControllerExpando[this] = controller;

      // TODO: hook close when controller is disposed
    }
    return controller;
  }

  /// A [Stream] of cache events received by this client.
  Stream<Object?> get onCacheUpdate =>
      _getOrCreateCacheUpdateController().stream;
  void notifyCacheUpdate(Object? event) {
    if (_getOrCreateCacheUpdateController().hasListener) {
      _getOrCreateCacheUpdateController().add(event);
    }
  }
}
