// For presentational widgets/models that use Flutter + domain
// types/utilities but never touch the ChangeNotifier provider tree
// directly (no Consumer/Provider.of/context.read/watch, no provider
// class references). Narrower than application.dart, which also pulls
// in every provider via app_providers.dart.
export 'app_external.dart';
export 'app_core.dart';
