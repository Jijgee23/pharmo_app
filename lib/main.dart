import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pharmo_app/app_configs.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/database/loc_model.dart';
import 'package:pharmo_app/database/log_model.dart';
import 'package:pharmo_app/models/a_models.dart';
import 'package:pharmo_app/services/a_services.dart';
import 'package:pharmo_app/services/battery_service.dart';
import 'package:pharmo_app/services/log_service.dart';
import 'package:pharmo_app/utilities/global_key.dart';
import 'package:pharmo_app/theme/dark_theme.dart';
import 'package:pharmo_app/theme/light_theme.dart';
import 'package:pharmo_app/views/auth/root_page.dart';
import 'package:upgrader/upgrader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseApi.initFirebase();
  await Upgrader.clearSavedSettings();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  Hive.registerAdapter(SecurityAdapter());
  Hive.registerAdapter(LocModelAdapter());
  Hive.registerAdapter(LogModelAdapter());
  await LocalBase.initLocalBase();
  await ConnectivityService.startListennetwork();
  await BatteryService.startListenBattery();
  await LogService().initialize();
  runApp(
    MultiProvider(
      providers: AppConfigs.providers,
      child: Pharmo(),
    ),
  );
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
    checkHasTrack(AppLifecycleState.resumed);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    checkHasTrack(state);
  }

  void checkHasTrack(AppLifecycleState state) async {
    Security? security = LocalBase.security;
    if (security == null || (security != null && security.role == 'PA')) {
      return;
    }
    print(security.role);
    if (security.role == "S") {
      final lp = context.read<LocationProvider>();
      bool hasTrack = await LocalBase.hasSellerTrack();
      await lifeCycleLog(state);
      if (hasTrack &&
          (lp.positionSubscription == null ||
              lp.positionSubscription!.isPaused)) {
        lp.startTracking();
        FirebaseApi.local('Борлуулалт дуусаагүй', 'Байршил дамжуулж байна');
        return;
      }
    }
    if (security.role == "D") {
      int delmanTrackId = await LocalBase.getDelmanTrackId();
      print('delman track id: $delmanTrackId');
      if (delmanTrackId == 0) return;
      await lifeCycleLog(state);
      final provider = context.read<JaggerProvider>();
      bool isStopped = (provider.positionSubscription == null ||
          provider.positionSubscription!.isPaused);
      if (isStopped) provider.tracking();
    }
  }

  Future lifeCycleLog(AppLifecycleState state) async {
    String desc = '';
    switch (state) {
      case AppLifecycleState.paused:
        desc = LogService.closeApp;
      case AppLifecycleState.detached:
        desc = LogService.terminateApp;
      default:
        desc = "unknown";
    }
    if (desc == "unknown") return;
    // await LogService.createLog('lifecycle action', desc);
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
        darkTheme: darkTheme,
        navigatorKey: GlobalKeys.navigatorKey,
        themeMode: home.themeMode,
        home: UpgradeAlert(
          dialogStyle: UpgradeDialogStyle.material,
          showIgnore: false,
          showLater: false,
          showReleaseNotes: false,
          child: RootPage(),
        ),
      ),
    );
  }
}
