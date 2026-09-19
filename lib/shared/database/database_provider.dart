import 'package:bonfire/shared/database/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

/// The single, app-wide Drift database instance. This is the source of truth
/// for cached entities - kept alive for the lifetime of the app so watch
/// queries can be shared across every screen without reopening the db.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
