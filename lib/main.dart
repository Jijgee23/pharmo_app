import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pharmo_app/app_configs.dart';
import 'package:pharmo_app/controller/providers/a_controlller.dart';
import 'package:pharmo_app/controller/database/log_model.dart';
import 'package:pharmo_app/controller/models/a_models.dart';
import 'package:pharmo_app/application/services/a_services.dart';
import 'package:pharmo_app/application/services/log_service.dart';
import 'package:pharmo_app/controller/database/track_data.dart';
import 'package:pharmo_app/application/utilities/global_key.dart';
import 'package:pharmo_app/application/theme/light_theme.dart';
import 'package:pharmo_app/views/auth/root_page.dart';
import 'package:pharmo_app/views/auth/splash_screen.dart';
import 'package:upgrader/upgrader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseApi.initFirebase();
    await Upgrader.clearSavedSettings();
    await dotenv.load(fileName: ".env");
    await Hive.initFlutter();
    Hive.registerAdapter(SecurityAdapter());
    Hive.registerAdapter(LogModelAdapter());
    Hive.registerAdapter(TrackDataAdapter());
    await LocalBase.initLocalBase();
    await LogService().initialize();
  } catch (error) {
    debugPrint('Error during initialization: $error');
    throw Exception('Initialization failed: $error');
  }
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
    bool splashed = LocalBase.hasSpashed;
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
        home: splashed ? RootPage() : SplashScreen(),
      ),
    );
  }
}
