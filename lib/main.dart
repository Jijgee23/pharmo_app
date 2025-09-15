import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/database/loc_model.dart';
import 'package:pharmo_app/models/a_models.dart';
import 'package:pharmo_app/services/a_services.dart';
import 'package:pharmo_app/utilities/global_key.dart';
import 'package:pharmo_app/theme/dark_theme.dart';
import 'package:pharmo_app/theme/light_theme.dart';
import 'package:pharmo_app/views/auth/root_page.dart';
import 'package:pharmo_app/views/auth/splash_screen.dart';
import 'package:upgrader/upgrader.dart';

const platform = MethodChannel('bg_location');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApi.initFirebase();
  Notify.initializeNotifications();
  await Upgrader.clearSavedSettings();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  Hive.registerAdapter(SecurityAdapter());
  Hive.registerAdapter(LocModelAdapter());
  await LocalBase.initLocalBase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => BasketProvider()),
        ChangeNotifierProvider(
            create: (_) => JaggerProvider()..startTracking()),
        ChangeNotifierProvider(create: (_) => MyOrderProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PharmProvider()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
        ChangeNotifierProvider(create: (_) => PromotionProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => RepProvider()..initTracking())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      checkHasTrack(state);
    } else if (state == AppLifecycleState.paused) {
      checkHasTrack(state);
    } else if (state == AppLifecycleState.detached) {
      print('detached');
      checkHasTrack(state);
    } else if (state == AppLifecycleState.inactive) {
      // print('inactive');
      // checkHasTrack(state);
    }
  }

  void checkHasTrack(AppLifecycleState state) async {
    Security? security = LocalBase.security;
    if (security == null || (security != null && security.role == 'PA')) {
      return;
    }
    if (security.role == "S") {
      context.read<LocationProvider>().initTracking();
      return;
    }
    if (security.role == "D") {
      context.read<LocationProvider>().startTracking();
      return;
    }
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
        darkTheme: darkTheme,
        navigatorKey: GlobalKeys.navigatorKey,
        themeMode: home.themeMode,
        home: UpgradeAlert(
          dialogStyle: UpgradeDialogStyle.material,
          showIgnore: false,
          showLater: false,
          showReleaseNotes: false,
          child: splashed == false ? SplashScreen() : RootPage(),
        ),
      ),
    );
  }
}
