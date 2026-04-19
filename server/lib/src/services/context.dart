import '../database/database.dart';
import '../realtime/realtime.dart';
import '../utils/env.dart';
import 'collections_cache.dart';
import 'hook_runner.dart';

/// Provides dependencies for service classes.
///
/// Services need database access but shouldn't depend on HTTP [Request].
/// This simple record provides the necessary dependencies.
typedef ServiceContext = ({
  AppDatabase database,
  Environment env,
  RealtimeEventBus? realtime,
  HookExecutor? hooks,
  CollectionsCache? collectionsCache,
});
