// Domain layer: models, enums, config, utilities, theme, services.
// No 3rd-party re-exports (see app_external.dart) and no ChangeNotifier
// providers (see app_providers.dart) — safe for presentational widgets
// that don't touch the provider tree.
export 'package:pharmo_app/authentication/role_managemant/user_permission.dart';
export 'package:pharmo_app/authentication/role_managemant/user_role.dart';
export 'package:pharmo_app/data/database/track_data.dart';
export 'package:pharmo_app/data/models/a_models.dart';
export 'package:pharmo_app/data/models/filters.dart' show Filters;
export 'package:pharmo_app/views/cart/a_cart.dart';
export 'package:pharmo_app/views/home/a_home.dart';
export 'package:pharmo_app/widgets/a_widgets.dart';

export 'config/app_configs.dart';
export 'const/asset_icon.dart';
export 'const/const.dart';
export 'const/queries.dart';
export 'enum/enums.dart';
export 'extension/extensions.dart';
export 'function/api/api_service.dart';
export 'function/utilities/a_utils.dart';
export 'native/native_channel.dart';
export 'settings/services/a_services.dart';
export 'settings/settings_page.dart';
export 'theme/dark_theme.dart';
export 'theme/light_theme.dart';
