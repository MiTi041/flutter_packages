import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  Future<void> saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Speichern einer Liste von Strings
  Future<void> saveStringList(String key, List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, list);
  }

  // Abrufen einer Liste von Strings
  Future<List<String>?> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  // Speichern eines Objekts als JSON
  Future<void> saveObject(String key, Map<String, dynamic> object) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(object));
  }

  // Abrufen eines Objekts aus JSON
  Future<Map<String, dynamic>?> getObject(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Speichern einer Liste von Objekten als JSON
  Future<void> saveObjectList(String key, List<List<Map<dynamic, dynamic>>> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(key, jsonList);
  }

  // Abrufen einer Liste von Objekten aus JSON
  Future<List<List<Map<dynamic, dynamic>>>> getObjectList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(key);

    if (jsonList != null) {
      return jsonList.map((item) => (jsonDecode(item) as List).map((e) => e as Map<dynamic, dynamic>).toList()).toList();
    }

    return [];
  }
}
