//main.dart

// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lists/components/floating_button.dart';
import 'package:lists/components/bottom_navigation_bar.dart';
import 'package:lists/components/page_content.dart';
import 'package:lists/components/schedule_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  // await SharedPreferences.getInstance()
  //   ..clear();
  // WidgetsFlutterBinding.ensureInitialized();

  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  // List<Map<String, dynamic>> formData = prefs
  //         .getStringList('form_data')
  //         ?.map((data) => Map<String, dynamic>.from(json.decode(data)))
  //         ?.toList() ??
  //     [];

  // print("Loaded FormData: $formData");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Color?>(
      future: SchedulePreferences().loadThemeColor(),
      builder: (context, snapshot) {
        final themeColor = snapshot.data;
        final materialColor = _convertToMaterialColor(themeColor);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lists',
          theme: ThemeData(
            primarySwatch:
                materialColor ?? _convertToMaterialColor(Colors.white),
            primaryColor: themeColor ?? Colors.white,
          ),
          home: MyHomePage(),
        );
      },
    );
  }

  MaterialColor? _convertToMaterialColor(Color? color) {
    if (color != null) {
      return MaterialColor(color.value, {
        50: color.withAlpha(0x1F),
        100: color.withAlpha(0x3F),
        200: color.withAlpha(0x5F),
        300: color.withAlpha(0x7F),
        400: color.withAlpha(0x9F),
        500: color.withAlpha(0xFF),
        600: color.withAlpha(0xDF),
        700: color.withAlpha(0xBF),
        800: color.withAlpha(0x9F),
        900: color.withAlpha(0x7F),
      });
    }
    return null;
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _getBody(_currentIndex),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: FutureBuilder<Color?>(
          future: SchedulePreferences().loadSelectedColor(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final Color selectedBackgroundColor = snapshot.data ??
                  Colors
                      .blue; // Use Colors.blue as default if snapshot.data is null
              return FloatingButtonMenu(
                refreshDayTile: () {
                  setState(() {});
                },
                selectedBackgroundColor: selectedBackgroundColor,
              );
            }
          },
        ));
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return PageContent('Home');
      case 1:
        return PageContent('Settings');
      default:
        return Container();
    }
  }
}
