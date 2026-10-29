import 'package:pharmo_app/application/app_lite.dart';

/// «2026.10.29» from «2026-10-29».
String logDateLabel(String date) => date.replaceAll('-', '.');

/// The supplier has printed the month and closed it: nothing can be changed.
class LogClosedBanner extends StatelessWidget {
  /// When and by whom, where known.
  final String? detail;
  const LogClosedBanner({super.key, this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Icon(Icons.lock_outline_rounded, size: 18, color: Colors.orange.shade700),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  'Энэ сарын журнал хаагдсан тул өөрчлөх боломжгүй.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
                if (detail != null)
                  Text(detail!, style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A reading's meter photo as a thumbnail; tapped, full screen.
class ReadingPhoto extends StatelessWidget {
  final String url;
  final double size;
  const ReadingPhoto({super.key, required this.url, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              InteractiveViewer(child: Center(child: _image(fit: BoxFit.contain))),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: white),
                ),
              ),
            ],
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: size, height: size, child: _image(fit: BoxFit.cover)),
      ),
    );
  }

  Widget _image({required BoxFit fit}) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              color: grey100,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      errorBuilder: (context, error, stack) => Container(
        color: grey100,
        alignment: Alignment.center,
        child: Icon(Icons.broken_image_outlined, color: grey400),
      ),
    );
  }
}
