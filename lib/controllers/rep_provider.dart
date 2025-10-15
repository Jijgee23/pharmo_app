import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'a_controlller.dart';
import 'package:pharmo_app/services/a_services.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/utilities/a_utils.dart';

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
    distanceFilter: 10,
  );

  Future<dynamic> addVisit(String note) async {
    try {
      if (note.isEmpty) {
        message('Тайлбар оруулна уу!');
      } else {
        final response =
            await api(Api.post, 'company/visit/', body: {"note": note});
        if (response!.statusCode == 200 || response.statusCode == 201) {
          await getActiveVisits();
          message('Уулзалт бүртгэгдлээ');
        } else {
          message('Уулзалт бүртгэхэд алдаа гарлаа!');
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
      final response = await api(Api.get, 'company/visit/');
      if (response!.statusCode == 200) {
        final data = convertData(response);
        final pref = await SharedPreferences.getInstance();
        visiting = Visiting.fromJson(data);
        print("visiting id: ${visiting!.id}");
        await pref.setInt('visitId', data['id']);
        notifyListeners();
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<dynamic> editVisit(int id, String note) async {
    try {
      print(note);
      final response = await api(
        Api.patch,
        'company/visit/',
        body: {"visit_id": id, "note": note},
      );
      if (response!.statusCode == 200 || response.statusCode == 201) {
        await getActiveVisits();
        message('Амжилттай засагдлаа');
      } else {
        message(wait);
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
      final response = await api(
        Api.patch,
        'company/visit/',
        body: {
          "visit_id": id,
          "visited_on": visitedOn,
          "lat": loc.latitude,
          "lng": loc.longitude
        },
      );
      if (response!.statusCode == 200 || response.statusCode == 201) {
        await getActiveVisits();
        message('Уулзалтын байршил илгээлээ');
      } else {
        message(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  bool isTracking = false;

  Future<dynamic> start() async {
    if (!await Settings.checkAlwaysLocationPermission()) {
      return;
    }
    await getActiveVisits();
    String outOn = DateTime.now().toString().substring(0, 19);
    Box db = await Hive.openBox('meeting');
    try {
      final body = {
        "visiting_id": visiting!.id,
        "out_on": outOn,
        "lat": currentPosition!.latitude,
        "lng": currentPosition!.longitude
      };
      final response = await api(Api.patch, 'company/visiting/', body: body);
      if (response!.statusCode == 200 || response.statusCode == 201) {
        isTracking = true;
        await db.delete('meetingId');
        await getActiveVisits();
        message('Уулзалтанд гарлаа');
        await db.put('meetingId', visiting!.id);
        startTracking();
      } else {
        message(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  startTracking() async {
    Box db = await Hive.openBox('meeting');
    if (db.get('meetingId') == null) {
      return;
    }
    // bg.BackgroundGeolocation.ready(
    //   bg.Config(
    //     desiredAccuracy: bg.Config.ACTIVITY_TYPE_OTHER_NAVIGATION,
    //     distanceFilter: 10.0,
    //     stopOnTerminate: false,
    //     startOnBoot: true,
    //     debug: false,
    //     logLevel: bg.Config.LOG_LEVEL_VERBOSE,
    //   ),
    // );
    // bg.BackgroundGeolocation.onLocation((pos) async {
    //   shareLocation(pos.coords.latitude, pos.coords.longitude);
    // }, (pos) {
    //   Notify.local(
    //       '', 'Байршил дамжуулах чадсангүй, байршил дамжуулах дарна уу!');
    // });
    // await bg.BackgroundGeolocation.start().then((c) {
    //   print(c);
    //   if (c.enabled) {
    //     message('Байршил дамжуулж эхлэлээ!');
    //   }
    // });
  }

  List<Loc> noSendedLocs = [];

  shareLocation(double lat, double lng) async {
    Box db = await Hive.openBox('meeting');
    try {
      if (db.get('meetingId') == null) {
        message('Уулзалт олдсонгүй');
        return;
      }
      final results = await Connectivity().checkConnectivity();
      if (!results.contains(ConnectivityResult.wifi) &&
          !results.contains(ConnectivityResult.mobile)) {
        await FirebaseApi.local(
          '📡 Сүлжээ тасарсан байна',
          'Интернет холболтоо шалгана уу. Байршлын дамжуулалт түр зогссон.',
        );
        noSendedLocs.add(Loc(lat: lat, lng: lng, created: DateTime.now()));
        notifyListeners();
        return;
      }
      final body = {"visiting_id": db.get('meetingId'), "lat": lat, "lng": lng};
      final res = await api(Api.patch, 'company/visiting/route/', body: body);
      if (res != null && res.statusCode == 200) {
        await FirebaseApi.local(
          'Байршил дамжуулж байна',
          'Таны байршлыг арын төлөвт дамжуулж байна. өргөрөг: $lat уртраг: $lng',
        );
        noSendedLocs.clear();
        notifyListeners();
      } else {
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
    // bg.BackgroundGeolocation.stop();
    isTracking = false;
    notifyListeners();
  }

  void initTracking() {
    startTracking();
  }

  Future<dynamic> endVisiting() async {
    String outOn = DateTime.now().toString().substring(0, 19);
    await getActiveVisits();
    final pref = await SharedPreferences.getInstance();
    int? vId = pref.getInt('visitId');
    Position newPosition = await Geolocator.getCurrentPosition();
    try {
      final response = await api(
        Api.patch,
        'company/visiting/',
        body: {
          "visiting_id": vId,
          "back_on": outOn,
          "lat": newPosition.latitude,
          "lng": newPosition.longitude
        },
      );
      if (response!.statusCode == 200 || response.statusCode == 201) {
        await getActiveVisits();
        message('Уулзалт дууслаа');
        stopTracking();
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
      final response = await api(
        Api.patch,
        'company/visit/',
        body: {"visit_id": id, "left_on": leftOn},
      );
      if (response!.statusCode == 200 || response.statusCode == 201) {
        await getActiveVisits();
        message('Уулзалтыг дуусгалаа');
      } else {
        message(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<dynamic> deleteVisit(int id) async {
    try {
      final response = await api(Api.delete, 'company/visit/?visit_id=$id');
      if (response!.statusCode == 200 || response.statusCode == 201) {
        await getActiveVisits();
        message('Амжилттай хасагдлаа');
      } else {
        message(wait);
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
