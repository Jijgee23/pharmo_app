import 'package:hive/hive.dart';

Future<Map<String, String>?> getSavedCredentials() async {
  final box = Hive.box('auth');
  final email = box.get('user_email');
  final password = box.get('user_password');

  if (email != null && password != null) {
    return {'email': email, 'password': password};
  }
  return null;
}

Future<void> saveLoginCredentials(String email, String password) async {
  final box = Hive.box('auth');
  await box.put('user_email', email);
  await box.put('user_password', password);
}
