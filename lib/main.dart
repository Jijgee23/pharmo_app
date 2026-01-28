import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pharmo_app/views/auth/root/root_page.dart';
import 'package:upgrader/upgrader.dart';
import 'application/application.dart';

final pharmo = Pharmo();

Future<void> main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FirebaseApi.initFirebase();
    await Upgrader.clearSavedSettings();
    await dotenv.load(fileName: ".env");
    await Hive.initFlutter();
    Hive.registerAdapter(SecurityAdapter());
    Hive.registerAdapter(LogModelAdapter());
    Hive.registerAdapter(TrackDataAdapter());
    await LocalBase.initLocalBase();
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
  }, (error, stack) async {
    await apiMacsMn(error, stack);
    debugPrint("ERROR=======> ${error.toString()}");
    debugPrint("ERROR=======> ${stack.toString()}");
  });
}

class Pharmo extends StatefulWidget {
  const Pharmo({super.key});
  @override
  State<Pharmo> createState() => _PharmoState();
}

class _PharmoState extends State<Pharmo> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    resumeWhenHasTrack(AppLifecycleState.resumed);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      resumeWhenHasTrack(state);
    }
  }

  void resumeWhenHasTrack(AppLifecycleState state) async {
    Security? security = LocalBase.security;
    if (security == null || (security != null && security.role == 'PA')) {
      return;
    }
    Future.microtask(
      () async {
        return await context.read<JaggerProvider>().tracking();
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) => GetMaterialApp(
        title: 'Pharmo app',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        locale: Locale("en-MN"),
        routes: AppConfigs.appRoutes,
        darkTheme: lightTheme,
        navigatorKey: GlobalKeys.navigatorKey,
        themeMode: home.themeMode,
        home: RootPage(),
      ),
    );
  }
}
//
