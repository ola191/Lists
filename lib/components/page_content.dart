//page_content.dart

import 'package:flutter/material.dart';
import 'schedule_preferences.dart';
import 'package:intl/intl.dart';
// import 'floating_button.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PageContent extends StatefulWidget {
  final String content;

  PageContent(this.content, {Key? key}) : super(key: key);

  @override
  _PageContentState createState() => _PageContentState();

  void refreshDayTile() {}
}

class _PageContentState extends State<PageContent> {
  DateTime currentDate = DateTime.now();
  late String formattedDate;
  List<String> days = [];

  Color _themeColor = Colors.white;
  Color _additionalColor = Colors.blueAccent;
  bool _option1 = false;
  bool _option2 = false;

  GlobalKey containerKey = GlobalKey();
  double containerHeight = 0.0;

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('dd-MM-yyyy').format(currentDate);
    _loadThemeColor();
    _loadSelectedColor();
  }

  void refreshDayTile() {
    setState(() {});
  }

  Color _parseColor(String colorString) {
    return Color(int.parse(colorString));
  }

  void _loadSelectedColor() async {
    Color? selectedColor = await SchedulePreferences().loadSelectedColor();
    if (selectedColor != null) {
      setState(() {
        _additionalColor = selectedColor;
      });
    }
  }

  void _loadThemeColor() async {
    Color? themeColor = await SchedulePreferences().loadThemeColor();
    if (themeColor != null) {
      setState(() {
        _themeColor = themeColor;
      });
    }
  }

  void _changeThemeColor(Color color) {
    setState(() {
      _themeColor = color;
    });
  }

  void _changeAdditionalColor(Color color) {
    setState(() {
      _additionalColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: getContentWidget(),
    );
  }

  Widget getContentWidget() {
    if (widget.content == 'Home') {
      return buildHome();
    } else if (widget.content == 'Settings') {
      return buildSettings();
    } else {
      return buildNotFound();
    }
  }

  Widget buildHome() {
    return Container(
      color: Theme.of(context).primaryColorDark,
      child: FutureBuilder<List<String>>(
        future: SchedulePreferences().loadDays(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            days = snapshot.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  key: containerKey,
                  child: Column(
                    children: [
                      buildWeekSlider(),
                      const Divider(height: 10, thickness: 5),
                    ],
                  ),
                ),
                buildDayTile(key: UniqueKey()),
              ],
            );
          }
        },
      ),
    );
  }

  void refreshUI() {
    setState(() {});
  }

  Widget buildWeekSlider() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 25,
                  ),
                  onPressed: () {
                    navigateToPreviousDay();
                  },
                ),
                Text(
                  'Day: $formattedDate',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 25,
                  ),
                  onPressed: () {
                    navigateToNextDay();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  void navigateToPreviousDay() {
    setState(() {
      currentDate = currentDate.subtract(const Duration(days: 1));
      formattedDate = DateFormat('dd-MM-yyyy').format(currentDate);
    });
  }

  void navigateToNextDay() {
    setState(() {
      currentDate = currentDate.add(const Duration(days: 1));
      formattedDate = DateFormat('dd-MM-yyyy').format(currentDate);
    });
  }

  Widget buildDayTile({Key? key}) {
    return FutureBuilder<List<dynamic>>(
      key: key,
      future: SchedulePreferences().loadFormData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<dynamic> formData = snapshot.data ?? [];

          DateTime actualDate = DateTime.now();

          List<Widget> hourListTiles = List.generate(25, (index) {
            List<Widget> hourItems = [];
            bool hasItem = false;

            for (var item in formData) {
              int startHour = item['start'] ?? -1;
              int duration = item['duration'] ?? -1;

              int elementHour = item['start'] + item['hours'];

              DateTime newFormattedDate =
                  DateFormat('dd-MM-yyyy').parse(formattedDate);

              DateTime elementDate = DateTime(
                  newFormattedDate.year,
                  newFormattedDate.month,
                  newFormattedDate.day,
                  elementHour,
                  0,
                  0);
              bool wasDone = false;
              if (elementDate.isAfter(actualDate)) {
                wasDone = true;
              }
              if (formattedDate ==
                  DateFormat('dd-MM-yyyy')
                      .format(DateTime.parse(item['date']))) {
                if (startHour == index) {
                  hourItems.add(ListTile(
                    title: Text(item['name'].toUpperCase() ?? ''),
                    titleTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    // shape: wasDone
                    //     ? Border.all(color: Colors.greenAccent, width: 3)
                    //     : Border.all(color: Colors.redAccent, width: 3),
                    leading: Container(
                        height: double.infinity,
                        child: wasDone
                            ? const Icon(Icons.cancel, color: Colors.redAccent)
                            : const Icon(Icons.check_circle,
                                color: Colors.greenAccent)),
                    subtitle: Text(
                        'Start : ${item['start']?.toString() ?? ''} \nEnd : ${(item['start'] + item['hours'] - 1)?.toString() ?? ''}'),
                    tileColor: Color(item['background_color'] ?? 0xFFFFFFFF),
                    textColor: Color(item['text_color'] ?? 0xFFFFFFFF),
                    trailing: const Icon(Icons.drag_handle),
                    dense: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String newName = '';
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    int myId =
                                        int.tryParse(item['id'].toString()) ??
                                            -1;
                                    if (myId != -1) {
                                      await SchedulePreferences()
                                          .deleteItemById(myId);
                                      refreshUI();
                                      Navigator.of(context).pop();
                                    } else {
                                      print('Invalid item ID');
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 5),
                                      Text(
                                        'DELETE',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: 10), // Add spacing between buttons
                                TextButton(
                                  onPressed: () {
                                    // Show a dialog to edit the item name
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Edit Item Name'),
                                          content: TextField(
                                            onChanged: (value) {
                                              newName =
                                                  value; // Update the new name
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Enter new name',
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () async {
                                                // Update the item name
                                                int myId = int.tryParse(
                                                        item['id']
                                                            .toString()) ??
                                                    -1;
                                                if (myId != -1) {
                                                  await SchedulePreferences()
                                                      .updateItemName(
                                                          myId, newName);
                                                  refreshUI();
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context)
                                                      .pop(); // Close the main dialog
                                                } else {
                                                  print('Invalid item ID');
                                                }
                                              },
                                              child: Text('SAVE'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the edit dialog
                                              },
                                              child: Text('CANCEL'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blue),
                                      SizedBox(width: 5),
                                      Text(
                                        'EDIT',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ));
                  hasItem = true;
                } else if (startHour < index && startHour + duration > index) {
                  hourItems.add(ListTile(
                    title: Text(item['name'] ?? ''),
                    subtitle: Text(item['start']?.toString() ?? ''),
                    tileColor: Color(item['background_color'] ?? 0xFFFFFFFF),
                    textColor: Color(item['text_color'] ?? 0xFFFFFFFF),
                    trailing: const Icon(Icons.drag_handle),
                    dense: true,
                    onTap: () {},
                  ));
                  hasItem = true;
                }
              } else {}
            }

            if (!hasItem) {
              hourItems.add(ListTile(
                title: const Text(''),
                subtitle: const Text(''),
                enabled: false,
                shape: const Border(
                  top: BorderSide(width: 1),
                ),
                onTap: () {},
              ));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: hourItems,
            );
          });

          List<Widget> Test = List.generate(24, (index) {
            return hourListTiles[index] ?? const SizedBox();
          });

          final RenderBox renderBox =
              containerKey.currentContext!.findRenderObject() as RenderBox;
          containerHeight = renderBox.size.height;
          return SizedBox(
            height: MediaQuery.of(context).size.height -
                kBottomNavigationBarHeight -
                containerHeight -
                10,
            child: LimitedBox(
              maxHeight: MediaQuery.of(context).size.height -
                  kBottomNavigationBarHeight -
                  containerHeight -
                  10,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Container(
                  child: Column(children: Test),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildSettings() {
    return Container(
      color: Theme.of(context).primaryColorDark,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 42.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double containerHeight = constraints.maxHeight;
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Divider(),
                    Text(
                      'Theme',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Divider(),

                    ListTile(
                      title: Text('Theme Color (reopen app)'),
                      trailing: GestureDetector(
                        onTap: () {
                          _showThemeColorPicker();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.black),
                            shape: BoxShape.circle,
                            color: _themeColor,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text('Additional Color'),
                      trailing: GestureDetector(
                        onTap: () {
                          _showAdditionalColorPicker();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.black),
                            shape: BoxShape.circle,
                            color: _additionalColor,
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(height: 20),
                    // Text(
                    //   'Options',
                    //   style:
                    //       TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    // ),
                    // CheckboxListTile(
                    //   title: Text('--- coming soon ---'),
                    //   value: _option1,
                    //   enabled: false,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _option1 = value!;
                    //     });
                    //   },
                    // ),
                    // CheckboxListTile(
                    //   title: Text('--- coming soon ---'),
                    //   value: _option2,
                    //   enabled: false,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _option2 = value!;
                    //     });
                    //   },
                    // ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showThemeColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick Theme Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _themeColor,
              onColorChanged: _changeThemeColor,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('SELECT'),
              onPressed: () {
                SchedulePreferences().saveThemeMode(_themeColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAdditionalColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick Additional Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _additionalColor,
              onColorChanged: (color) {
                setState(() {
                  _additionalColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('SELECT'),
              onPressed: () {
                SchedulePreferences().saveSelectedColor(_additionalColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildNotFound() {
    return Container(
      child: const Text(
        "Not Found",
        style: TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
