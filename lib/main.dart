import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pharmo_app/authentication/root/root_page.dart';
import 'package:upgrader/upgrader.dart';
import 'application/application.dart';

Future<void> main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await FirebaseApi.initFirebase();
      await Upgrader.clearSavedSettings();
      await dotenv.load(fileName: ".env");
      await Hive.initFlutter();
      Hive.registerAdapter(SecurityAdapter());
      Hive.registerAdapter(LogModelAdapter());
      Hive.registerAdapter(TrackDataAdapter());
      await Authenticator.initAuthenticator();
      await LogService().initialize();
      runApp(
        UpgradeAlert(
          dialogStyle: UpgradeDialogStyle.material,
          showIgnore: false,
          showLater: true,
          showReleaseNotes: false,
          child: MultiProvider(
            providers: AppConfigs.providers,
            child: Pharmo(),
          ),
        ),
      );
    },
    (error, stack) async {
      await apiMacsMn(error, stack);
      debugPrint("ERROR=======> ${error.toString()}");
      debugPrint("ERROR=======> ${stack.toString()}");
    },
  );
}

class Pharmo extends StatelessWidget {
  const Pharmo({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) => GetMaterialApp(
        title: 'Pharmo app',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        locale: Locale('mn', 'MN'),
        routes: AppConfigs.appRoutes,
        supportedLocales: AppConfigs.locales,
        localizationsDelegates: AppConfigs.localizations,
        darkTheme: lightTheme,
        navigatorKey: GlobalKeys.navigatorKey,
        themeMode: home.themeMode,
        home: RootPage(),
      ),
    );
  }
}
