//schedule_preferences.dart

import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchedulePreferences {
  static const String weekKey = 'schedule_week';
  static const String themeModeKey = 'theme_mode';
  static const String selectedColorKey = 'selected_color';
  // static const String _formDataKey = 'formData';

  // Function to save the selected theme mode
  Future<void> saveThemeMode(Color color) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeModeKey, color.value);
  }

  Future<Color?> loadThemeColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? colorValue = prefs.getInt(themeModeKey);
    return colorValue != null ? Color(colorValue) : null;
  }

  // Function to save the selected color
  Future<void> saveSelectedColor(Color color) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(selectedColorKey, color.value);
  }

  // Function to load the selected color
  Future<Color?> loadSelectedColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? colorValue = prefs.getInt(selectedColorKey);
    return colorValue != null ? Color(colorValue) : null;
  }

  Future<void> saveFormData(int id, String name, Color backgroundColor,
      Color textColor, int start, int hours, String date) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> formData = prefs
            .getStringList('form_data')
            ?.map((data) => Map<String, dynamic>.from(json.decode(data)))
            ?.toList() ??
        [];

    formData.add({
      'id': id,
      'name': name,
      'background_color': backgroundColor.value, // Changed
      'text_color': textColor.value, // New
      'start': start,
      'hours': hours,
      'date': date,
    });

    prefs.setStringList(
        'form_data', formData.map((data) => json.encode(data)).toList());
  }

  Future<int> countItems() async {
    final List<Map<String, dynamic>> formData = await loadFormData();
    int totalCount = 0;

    for (final entry in formData) {
      totalCount++;
    }

    return totalCount;
  }

  Future<void> saveWeek(List<Map<String, dynamic>> weekSchedule) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String weekJson = json.encode(weekSchedule);
    await prefs.setString(weekKey, weekJson);
  }

  Future<List<Map<String, dynamic>>> loadWeek() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? weekJson = prefs.getString(weekKey);

    if (weekJson != null) {
      List<Map<String, dynamic>> weekData =
          List<Map<String, dynamic>>.from(json.decode(weekJson));
      return weekData;
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> loadFormData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> formData = prefs
            .getStringList('form_data')
            ?.map((data) => Map<String, dynamic>.from(json.decode(data)))
            ?.toList() ??
        [];

    // Print the loaded data
    return formData;
  }

  Future<List<String>> loadDays() async {
    final List<Map<String, dynamic>> weekSchedule = await loadWeek();
    return weekSchedule
        .map<String>((dayData) => dayData['day'] as String)
        .toList();
  }

  // Additional functions for adding, editing, and deleting items
  Future<void> addItemToDay(String day, Map<String, dynamic> item) async {
    final List<Map<String, dynamic>> weekSchedule = await loadWeek();
    final Map<String, dynamic>? daySchedule = weekSchedule.firstWhereOrNull(
      (element) => element['day'] == day,
    );

    if (daySchedule != null) {
      daySchedule['items']?.add(item);
    } else {
      weekSchedule.add({
        'day': day,
        'items': [item]
      });
    }

    await saveWeek(weekSchedule);
  }

  Future<void> updateItemName(int itemId, String newName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? formDataStringList = prefs.getStringList('formData');
    if (formDataStringList != null) {
      List formData = formDataStringList.map((e) => jsonDecode(e)).toList();
      for (int i = 0; i < formData.length; i++) {
        if (formData[i]['id'] == itemId) {
          formData[i]['name'] = newName;
          break;
        }
      }
      List<String> updatedFormDataStringList =
          formData.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList('formData', updatedFormDataStringList);
    }
  }

  Future<void> deleteItemById(int id) async {
    final List<Map<String, dynamic>> formData = await loadFormData();
    print(id);
    for (final entry in formData) {
      if (entry['id'] == id) {
        formData.remove(entry);
        break;
      }
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'form_data', formData.map((data) => json.encode(data)).toList());
  }
}
