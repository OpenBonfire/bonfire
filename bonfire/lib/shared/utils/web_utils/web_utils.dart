import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void initializePlatform() {
  setUrlStrategy(PathUrlStrategy());
}
