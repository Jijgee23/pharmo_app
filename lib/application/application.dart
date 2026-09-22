// Aggregates the app's full dependency surface. Most files should keep
// importing this — but a file that only needs Flutter + domain
// types/utilities and never touches the provider tree can import
// app_lite.dart instead for a narrower dependency footprint.
export 'app_external.dart';
export 'app_providers.dart';
export 'app_core.dart';
