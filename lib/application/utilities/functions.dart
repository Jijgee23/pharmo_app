// import 'package:pharmo_app/application/application.dart';
// import 'package:pharmo_app/controller/a_controlller.dart';

// Future<void> fullLogout() async {
//   final context = GlobalKeys.navigatorKey.currentContext;
//   if (context != null) {
//     try {
//       context.read<HomeProvider>().reset();
//       context.read<BasketProvider>().reset();
//       context.read<DriverProvider>().reset();
//       context.read<JaggerProvider>().reset();
//       context.read<LogProvider>().reset();
//       context.read<MyOrderProvider>().reset();
//       context.read<PharmProvider>().reset();
//       context.read<PromotionProvider>().reset();
//       context.read<ReportProvider>().reset();
//       debugPrint('Providers disposed');
//     } catch (e) {
// debugPrint('Error disposing providers: ${e.toString()}');
//     }
//   }
//   await LogService().createLog('logout', LogService.logout);
//   await LocalBase.removeTokens();
//   await LocalBase.saveLastLoggedIn(false);
//   final user = LocalBase.security;
//   if (user == null) {
//     await goNamedOfAll('login');
//     return;
//   }
//   final r = await api(Api.post, 'auth/logout/');
//   if (r == null) {
//     await goNamedOfAll('login');
//     return;
//   }

//   await goNamedOfAll('login');
// }
