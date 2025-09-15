// import 'package:hive/hive.dart';

// class Userservice {
//   static saveUserData(Map<String, dynamic> token, String password) async {
//     Box db = await Hive.openBox('auth');
//     await db.put('role', token['role']);
//     await db.put('name', token['name']);
//     await db.put('email', token['email']);
//     await db.put('company_name', token['company_name']);
//     await db.put('user_id', token['user_id']);
//     await db.put('password', password);
//   }

//   static Future<Map<String, dynamic>> getUserData() async {
//     Box db = await Hive.openBox('auth');
//     String? role = await db.get('role');
//     String? name = await db.get('name');
//     String? email = await db.get('email');
//     String? cName = await db.get('company_name');
//     int? userId = db.get('user_id');
//     String? password = db.get('password');
//     Map<String, dynamic> data = {
//       "role": role,
//       "name": name,
//       "email": email,
//       "companyName": cName,
//       "userId": userId,
//       "password": password
//     };
//     return data;
//   }

//   static Future clearUserData() async {
//     Box db = await Hive.openBox('auth');
//     db.clear();
//   }
// }
