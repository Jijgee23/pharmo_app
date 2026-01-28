import 'package:pharmo_app/application/application.dart';

class MapHeading extends StatelessWidget {
  final bool isSeller;
  final bool showTracking;
  const MapHeading({
    super.key,
    required this.isSeller,
    required this.showTracking,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 20,
      left: 20,
      child: SafeArea(
        child: SizedBox(
          width: ContextX(context).width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 20,
            children: [
              if (isSeller)
                FloatingActionButton(
                  heroTag: 'backST',
                  onPressed: () => Navigator.of(context).pop(),
                  backgroundColor: white,
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              if (showTracking)
                FloatingActionButton.extended(
                  heroTag: 'hasTrack2DMANMAPjk',
                  onPressed: () async {},
                  backgroundColor: Colors.teal,
                  label: Text(
                    'Байршил дамжуулж байна...',
                    style: TextStyle(color: white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
