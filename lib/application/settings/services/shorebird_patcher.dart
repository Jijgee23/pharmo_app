import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:pharmo_app/application/application.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Shorebird code push. Looks for a patch when the app starts and whenever
/// it returns to the foreground, downloads it, then has the user restart
/// straight away: a patch only runs from the next launch, and the old code
/// shouldn't keep running meanwhile. New store versions are UpdateDialog's.
///
/// Shorebird only runs in a build made with `shorebird release`. In a debug
/// build the restart dialog is shown once as a test instead (see
/// [_previewInDebug]); in any other build without Shorebird (a plain
/// `flutter build`) nothing happens.
class ShorebirdPatcher {
  ShorebirdPatcher._();

  static final ShorebirdUpdater _updater = ShorebirdUpdater();
  static bool _started = false;
  static bool _checking = false;
  static bool _prompted = false;

  /// Shows the restart dialog, marked as a test, once per launch of a debug
  /// build, where Shorebird is never available, so it can be seen and tried
  /// without a real patch. Turn off with
  /// `--dart-define=SHOREBIRD_PREVIEW=false`. Never in a release build.
  // static const _previewInDebug = bool.fromEnvironment('SHOREBIRD_PREVIEW', defaultValue: true);

  /// Call once. The first check waits for the first frame, when there is a
  /// navigator to show the restart dialog on.
  static void start() {
    if (_started) return;
    _started = true;
    // if (!_updater.isAvailable) {
    //   if (kDebugMode && _previewInDebug) {
    //     WidgetsBinding.instance.addPostFrameCallback((_) => _promptRestart(preview: true));
    //   }
    //   return;
    // }
    // Registered with the binding, which keeps it for the app's lifetime.
    AppLifecycleListener(onResume: checkForPatch);
    WidgetsBinding.instance.addPostFrameCallback((_) => checkForPatch());
  }

  /// Downloads a new patch if there is one, then asks for the restart.
  /// Failures only go to the log: the app carries on with what it has.
  static Future<void> checkForPatch() async {
    if (_checking || _prompted || !_updater.isAvailable) return;
    _checking = true;
    try {
      var status = await _updater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        await _updater.update(); // throws UpdateException if it fails
        status = UpdateStatus.restartRequired;
      }
      if (status == UpdateStatus.restartRequired) await _promptRestart();
    } on UpdateException catch (e) {
      debugPrint('Shorebird: ${e.message}');
    } catch (e) {
      debugPrint('Shorebird: $e');
    } finally {
      _checking = false;
    }
  }

  /// The restart dialog on its own, e.g. to render a preview of it.
  @visibleForTesting
  static Widget restartDialog({bool preview = false}) => _RestartDialog(preview: preview);

  static Future<void> _promptRestart({bool preview = false}) async {
    final context = Get.context ?? GlobalKeys.navigatorKey.currentContext;
    if (context == null) return; // tried again on the next resume
    _prompted = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RestartDialog(preview: preview),
    );
  }
}

/// Can't be dismissed: the only way on is the restart. As a [preview] it is
/// marked «ТЕСТ» and its button just closes it.
class _RestartDialog extends StatefulWidget {
  final bool preview;
  const _RestartDialog({this.preview = false});

  @override
  State<_RestartDialog> createState() => _RestartDialogState();
}

class _RestartDialogState extends State<_RestartDialog> {
  bool _restarting = false;

  // Shorebird picks the patch when the process starts, so this has to be a
  // new process: an in-process engine restart would boot the old code and
  // ask again. Android relaunches one; iOS can't, so the app exits and a
  // notification offers to reopen it.
  Future<void> _restart() async {
    if (widget.preview) {
      // Restarting would end the debug session; say what would happen.
      Navigator.pop(context);
      message('Тест: жинхэнэ шинэчлэлтийн үед апп энд дахин эхэлнэ.');
      return;
    }
    setState(() => _restarting = true);
    var restarted = false;
    try {
      final result = await Restart.restartApp(
        mode: Platform.isIOS ? RestartMode.notificationFallback : RestartMode.process,
        notificationTitle: 'Pharmo шинэчлэгдлээ',
        notificationBody: 'Энд дарж аппаа дахин нээнэ үү.',
      );
      restarted = result.success;
    } catch (e) {
      debugPrint('restart failed: $e');
    }
    // Only reached if the app is still running.
    if (!restarted && mounted) {
      setState(() => _restarting = false);
      messageWarning('Аппаа бүрэн хаагаад дахин нээнэ үү.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tint = context.theme.primaryColor;
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tint.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.system_update_rounded, size: 36, color: tint),
              ),
              const SizedBox(height: 18),
              if (widget.preview) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ТЕСТ · debug build',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber.shade900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                'Шинэчлэлт бэлэн боллоо',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                defaultTargetPlatform == TargetPlatform.iOS
                    ? 'Аппын шинэ хувилбар татагдлаа. Апп хаагдах тул мэдэгдэл дээр дарж эсвэл дахин нээж үргэлжлүүлнэ үү.'
                    : 'Аппын шинэ хувилбар татагдлаа. Үргэлжлүүлэхийн тулд аппыг дахин эхлүүлнэ үү.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: grey600, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _restarting ? null : _restart,
                  icon: _restarting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.restart_alt_rounded),
                  label: const Text('Дахин эхлүүлэх'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
