import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:pharmo_app/application/application.dart';

class RepProvider extends ChangeNotifier {
  Visiting? visiting;

  bool loading = false;
  setLoading(bool n) {
    WidgetsBinding.instance.addPostFrameCallback((cb) {
      loading = n;
      notifyListeners();
    });
  }

  Position? currentPosition;
  setPosition() async {
    Position newPosition = await Geolocator.getCurrentPosition();
    currentPosition = newPosition;
    notifyListeners();
  }

  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 6,
  );

  Future<dynamic> addVisit(String note) async {
    try {
      if (note.isEmpty) {
        messageWarning('Тайлбар оруулна уу!');
      } else {
        final r = await api(Api.post, 'company/visit/', body: {"note": note});
        if (r == null) return;
        if (r.statusCode == 200 || r.statusCode == 201) {
          await getActiveVisits();
          messageComplete('Уулзалт бүртгэгдлээ');
        } else {
          messageWarning('Уулзалт бүртгэхэд алдаа гарлаа!');
        }
      }
    } catch (e) {
      //
    } finally {
      notifyListeners();
    }
  }

  Future<dynamic> getActiveVisits() async {
    try {
      setLoading(true);
      final r = await api(Api.get, 'company/visit/');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        visiting = Visiting.fromJson(data);
        notifyListeners();
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  // The API rejects any PATCH to /company/visit/ or /company/visiting/
  // with {"visiting": "ended"} once the visiting session has a back_on —
  // surface that specifically instead of the generic "wait" message, which
  // would otherwise tell the user to retry a call that can never succeed.
  bool _isVisitingEndedError(dynamic r) {
    if (r == null) return false;
    try {
      final data = convertData(r);
      return data is Map && data['visiting'] == 'ended';
    } catch (_) {
      return false;
    }
  }

  void _warnMutationFailure(dynamic r) {
    if (_isVisitingEndedError(r)) {
      messageWarning('Уулзалт аль хэдийн дууссан байна');
    } else {
      messageWarning(wait);
    }
  }

  Future<dynamic> editVisit(int id, String note) async {
    try {
      final r = await api(
        Api.patch,
        'company/visit/',
        body: {"visit_id": id, "note": note},
      );
      if (r == null) {
        messageWarning(wait);
        return;
      }
      if (r.statusCode == 200 || r.statusCode == 201) {
        await getActiveVisits();
        messageComplete('Амжилттай засагдлаа');
      } else {
        _warnMutationFailure(r);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<dynamic> comedVisit(int id) async {
    String visitedOn = DateTime.now().toString().substring(0, 19);
    try {
      Position loc = await Geolocator.getCurrentPosition();
      final r = await api(
        Api.patch,
        'company/visit/',
        body: {
          "visit_id": id,
          "visited_on": visitedOn,
          "lat": loc.latitude,
          "lng": loc.longitude
        },
      );
      if (r == null) {
        messageWarning(wait);
        return;
      }
      if (r.statusCode == 200 || r.statusCode == 201) {
        await getActiveVisits();
        messageComplete('Уулзалтын байршил илгээлээ');
      } else {
        _warnMutationFailure(r);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  bool isTracking = false;
  StreamSubscription<Position>? _positionSubscription;

  Future<dynamic> start() async {
    if (!await Settings.checkAlwaysLocationPermission()) {
      return;
    }
    await getActiveVisits();
    // Was reading the currentPosition field, which is only ever populated
    // by SeeMap.initState() — tapping "Уулзалтанд гарах" without having
    // opened the map first hit a null-check exception here, silently
    // swallowed by the catch below with zero feedback to the user. Fetch a
    // fresh fix directly, same as endVisiting() already does.
    final position = await Geolocator.getCurrentPosition();
    currentPosition = position;
    String outOn = DateTime.now().toString().substring(0, 19);
    Box db = await Hive.openBox('meeting');
    try {
      final body = {
        "visiting_id": visiting!.id,
        "out_on": outOn,
        "lat": position.latitude,
        "lng": position.longitude
      };
      final r = await api(Api.patch, 'company/visiting/', body: body);
      if (r == null) return;
      if (r.statusCode == 200 || r.statusCode == 201) {
        await db.delete('meetingId');
        await getActiveVisits();
        messageComplete('Уулзалтанд гарлаа');
        await db.put('meetingId', visiting!.id);
        await startTracking();
      } else {
        messageWarning(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Rep tracking is deliberately foreground-only — unlike Driver/Seller/
  // VanSales there is no native background service behind it, matching the
  // "Апп-аас гарах үед байршил дамжуулахгүй" warning already shown before
  // starting a visit (see RepHome._askStart). A plain Geolocator position
  // stream is the right amount of implementation for that documented
  // limitation, not a full NativeChannel/foreground-service integration.
  Future<void> startTracking() async {
    Box db = await Hive.openBox('meeting');
    if (db.get('meetingId') == null) return;

    await _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (position) => shareLocation(position.latitude, position.longitude),
      onError: (Object e) => debugPrint('Rep location stream error: $e'),
    );
    isTracking = true;
    notifyListeners();
  }

  DateTime? _lastTrackingNotifAt;
  static const _trackingNotifInterval = Duration(minutes: 3);

  // shareLocation() fires on every accepted position (distanceFilter: 6m
  // apart) — a local notification on every single one of those would spam
  // the user. Throttle both the "sending" and "not sending" notifications
  // to at most once per interval instead of once per GPS point.
  bool _shouldNotifyTracking() {
    final now = DateTime.now();
    if (_lastTrackingNotifAt == null || now.difference(_lastTrackingNotifAt!) > _trackingNotifInterval) {
      _lastTrackingNotifAt = now;
      return true;
    }
    return false;
  }

  Future<void> shareLocation(double lat, double lng) async {
    Box db = await Hive.openBox('meeting');
    try {
      if (db.get('meetingId') == null) return;

      final hasInternet = await NetworkChecker.hasInternet();
      if (!hasInternet) {
        if (_shouldNotifyTracking()) {
          await FirebaseApi.local(
            '📡 Сүлжээ тасарсан байна',
            'Интернет холболтоо шалгана уу. Байршлын дамжуулалт түр зогссон.',
          );
        }
        return;
      }
      final body = {"visiting_id": db.get('meetingId'), "lat": lat, "lng": lng};
      final r = await api(Api.patch, 'company/visiting/route/', body: body);
      if (r == null) return;
      if (r.statusCode == 200) {
        if (_shouldNotifyTracking()) {
          await FirebaseApi.local(
            'Байршил дамжуулж байна',
            'Таны байршлыг дамжуулж байна.',
          );
        }
      } else if (_shouldNotifyTracking()) {
        await FirebaseApi.local(
          'Байршил дамжуулаагүй!',
          'Байршил дамжуулах дарна уу!',
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    isTracking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<dynamic> endVisiting() async {
    String outOn = DateTime.now().toString().substring(0, 19);
    await getActiveVisits();
    // visiting is freshly refetched above via getActiveVisits(), so use its
    // id directly rather than a separately-persisted SharedPreferences
    // value that could in principle drift out of sync with it.
    final vId = visiting?.id;
    Position newPosition = await Geolocator.getCurrentPosition();
    try {
      final r = await api(
        Api.patch,
        'company/visiting/',
        body: {
          "visiting_id": vId,
          "back_on": outOn,
          "lat": newPosition.latitude,
          "lng": newPosition.longitude
        },
      );
      if (r == null) {
        messageWarning(wait);
        return;
      }
      if (r.statusCode == 200 || r.statusCode == 201) {
        await getActiveVisits();
        messageComplete('Уулзалт дууслаа');
        stopTracking();
      } else {
        _warnMutationFailure(r);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<dynamic> leftVisit(int id) async {
    String leftOn = DateTime.now().toString().substring(0, 19);
    try {
      final r = await api(
        Api.patch,
        'company/visit/',
        body: {"visit_id": id, "left_on": leftOn},
      );
      if (r == null) {
        messageWarning(wait);
        return;
      }
      if (r.statusCode == 200 || r.statusCode == 201) {
        await getActiveVisits();
        messageComplete('Уулзалтыг дуусгалаа');
      } else {
        _warnMutationFailure(r);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<dynamic> deleteVisit(int id) async {
    try {
      final r = await api(Api.delete, 'company/visit/?visit_id=$id');
      if (r == null) return;
      if (r.statusCode == 200 || r.statusCode == 201) {
        await getActiveVisits();
        messageComplete('Амжилттай хасагдлаа');
      } else {
        messageWarning(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }
}

class Visiting {
  final int id;
  final String? outOn;
  final String? backOn;
  List<Visit>? visits;
  Visiting({required this.id, this.outOn, this.backOn, this.visits});

  factory Visiting.fromJson(Map<String, dynamic> json) {
    return Visiting(
      id: parseInt(json['id']),
      outOn: json['out_on'],
      backOn: json['back_on'],
      visits: json['visits'] != null
          ? (json['visits'] as List).map((vis) => Visit.fromJson(vis)).toList()
          : null,
    );
  }
}

class Visit {
  final int id;
  final String note;
  final String? visitedOn;
  final String? leftOn;
  final double? lat;
  final double? lng;
  final int? addedBy;
  final String createdAt;
  Visit({
    required this.id,
    required this.note,
    this.visitedOn,
    this.leftOn,
    this.lat,
    this.lng,
    this.addedBy,
    required this.createdAt,
  });
  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] as int,
      note: json['note'].toString(),
      visitedOn: json['visited_on'],
      leftOn: json['left_on'],
      lat: json['lat'],
      lng: json['lng'],
      addedBy: json['added_by_id'],
      createdAt: json['created'].toString(),
    );
  }
}
