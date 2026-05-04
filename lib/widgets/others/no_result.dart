import 'package:pharmo_app/application/application.dart'; // primary, theme зэргийг авахын тулд

class NoResult extends StatelessWidget {
  final String? message;
  final String? subMessage;
  final VoidCallback? onRefresh;

  const NoResult({
    super.key,
    this.message,
    this.subMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Зураг (Илүү зөөлөн харагдуулахын тулд Opacity нэмсэн)
            Opacity(
              opacity: 0.7,
              child: Image.asset(
                'assets/icons/not-found.png',
                width: context.width * 0.3,
                fit: BoxFit.contain,
                // Хэрэв зураг байхгүй бол алдаа заахаас сэргийлнэ
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.search_off_rounded,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Үндсэн гарчиг
            Text(
              message ?? 'Үр дүн олдсонгүй',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),

            // 3. Туслах тайлбар
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
              child: Text(
                subMessage ?? 'Та хайх утгаа шалгах эсвэл дахин оролдож үзнэ үү.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500, letterSpacing: -.5),
              ),
            ),

            // 4. Дахин ачаалах товч (Сонголтоор)
            if (onRefresh != null) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Дахин ачаалах'),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
