import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserData(
  String token,
  String id,
  String name,
  String address,
  String phone,
  String role,
) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  await prefs.setString('id', id);
  await prefs.setString('name', name);
  await prefs.setString('address', address);
  await prefs.setString('phone', phone);
  await prefs.setString('role', role);
}

Future<void> saveOnBoardStatus(String status) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setString('onBoardStatus', status);
}

Future<void> saveLanguage(String lang) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setString('lang', lang);
}

Future<void> removeUserData() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.remove('token');
  await sharedPreferences.remove('id');
  await sharedPreferences.remove('name');
  await sharedPreferences.remove('address');
  await sharedPreferences.remove('phone');
  await sharedPreferences.remove('role');
}

Future<void> saveFcmTOKEN(String fcmToken) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setString('fcmToken', fcmToken);
}

Future<void> saveFirebaseUserID(String userId) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setString('userId', userId);
}

Future<void> removeFirebaseUserID() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.remove('userId');
}
