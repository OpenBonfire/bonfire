import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';
import 'package:universal_platform/universal_platform.dart';

Future<void> setupHive() async {
  if (!UniversalPlatform.isWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${appDocumentDir.path}/bonfire/data');
    if (!dataDir.existsSync()) {
      dataDir.createSync(recursive: true);
    }
    Hive.init(dataDir.path);
  }
  await Hive.openBox("auth");
  await Hive.openBox("last-location");
  await Hive.openBox("last-guild-channels");
  await Hive.openBox("added-accounts");
}
