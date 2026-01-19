class TrackService {
  static final TrackService _instance = TrackService._internal();
  TrackService._internal();
  factory TrackService() {
    return _instance;
  }

  bool tracking = false;
  bool isSeller = false;
  bool isDelman = false;

  Future saveDelmanTrack() async {}
  Future saveSellerTracking() async {}
  Future saveTrackToBox() async {}
}
