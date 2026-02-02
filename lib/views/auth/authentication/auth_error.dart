import 'package:pharmo_app/views/profile/profile.dart';
import 'package:pharmo_app/application/application.dart';

class AuthError extends StatelessWidget {
  const AuthError({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Илүү том, зөөлөн икон хэсэг
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  color: Colors.redAccent,
                  size: 80,
                ),
              ),

              const SizedBox(height: 40),

              // 2. Гарчиг
              const Text(
                'Нэвтрэх шаардлагатай',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // 3. Тайлбар текст
              Text(
                'Таны нэвтрэх хугацаа дууссан эсвэл хэрэглэгч олдсонгүй. Үргэлжлүүлэхийн тулд дахин нэвтэрнэ үү.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 50),

              // 4. Нэвтрэх товч
              CustomButton(
                text: 'Нэвтрэх хуудас руу очих',
                ontap: () => logout(context),
              ),

              const SizedBox(height: 20),

              // 5. Нэмэлт тусламж (заавал биш)
              // TextButton(
              //   onPressed: () {
              //     // Жишээ нь: Тусламж авах эсвэл Админтай холбогдох
              //   },
              //   child: Text(
              //     'Тусламж хэрэгтэй юу?',
              //     style: TextStyle(
              //       color: Colors.grey.shade500,
              //       fontSize: 13,
              //       decoration: TextDecoration.underline,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
