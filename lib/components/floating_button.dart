//floating_button.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'schedule_preferences.dart';

class FloatingButtonMenu extends StatefulWidget {
  final Function refreshDayTile;
  final Color selectedBackgroundColor;

  FloatingButtonMenu({
    required this.refreshDayTile,
    required this.selectedBackgroundColor, // Add this line
  });

  @override
  _FloatingButtonMenuState createState() => _FloatingButtonMenuState();
}

class _FloatingButtonMenuState extends State<FloatingButtonMenu> {
  late Future<Color?> _selectedBackgroundColorFuture;
  TextEditingController nameController = TextEditingController();
  int? selectedStart = 0;
  int? selectedHours = 1;
  Color selectedBackgroundColor = Colors.blue; // New
  Color selectedTextColor = Colors.black; // New
  String date = '';

  @override
  void initState() {
    super.initState();
    _selectedBackgroundColorFuture = SchedulePreferences().loadSelectedColor();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Color?>(
      future: _selectedBackgroundColorFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final Color? selectedBackgroundColor = snapshot.data;
          return FloatingActionButton(
            onPressed: () {
              showCircularMenu(context);
            },
            backgroundColor: selectedBackgroundColor,
            child: const Icon(
              Icons.add,
              color: Colors.black,
            ),
          );
        }
      },
    );
  }

  void showCircularMenu(BuildContext context) async {
    // Ensure that previously selected values are reset when showing the menu
    nameController.clear();
    selectedStart = 0;
    selectedHours = 1;
    selectedBackgroundColor = Colors.blue;
    selectedTextColor = Colors.black;
    date =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    // Show the bottom sheet with a draggable scrollable container
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableSheet(
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  controller: scrollController,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ColorPickerFormField(
                            labelText: 'Background Color', // New
                            onColorChanged: (Color color) {
                              setState(() {
                                selectedBackgroundColor = color;
                              });
                            },
                          ),
                          const SizedBox(height: 16.0),
                          ColorPickerFormField(
                            labelText: 'Text Color', // New
                            onColorChanged: (Color color) {
                              setState(() {
                                selectedTextColor = color;
                              });
                            },
                          ),
                        ]),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Start:'),
                        const SizedBox(width: 16.0),
                        DropdownButton<int>(
                          value: selectedStart,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedStart = value;
                              });
                            }
                          },
                          items: List.generate(24, (index) {
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Text('$index:00'),
                            );
                          }),
                        ),
                        Text('Hours:'),
                        const SizedBox(width: 16.0),
                        DropdownButton<int>(
                          value: selectedHours,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedHours = value;
                              });
                            }
                          },
                          items: List.generate(24, (index) {
                            return DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text('${index + 1}'),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Text('Date:'),
                            const SizedBox(width: 16.0),
                            ElevatedButton(
                              onPressed: () async {
                                DateTime? selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2101),
                                );

                                if (selectedDate != null) {
                                  String formattedDate =
                                      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                                  setState(() {
                                    date = formattedDate;
                                  });
                                } else {
                                  setState(() {
                                    date =
                                        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
                                  });
                                }
                              },
                              child: const Text('Select Date'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        String name = nameController.text.trim();
                        int id = await SchedulePreferences().countItems();
                        if (name.isNotEmpty) {
                          await SchedulePreferences().saveFormData(
                            id,
                            name,
                            selectedBackgroundColor, // Changed
                            selectedTextColor, // New
                            selectedStart!,
                            selectedHours!,
                            date,
                          );
                          widget.refreshDayTile();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }
}

class ColorPickerFormField extends StatefulWidget {
  final void Function(Color) onColorChanged;
  final String labelText; // New

  ColorPickerFormField({required this.onColorChanged, required this.labelText});

  @override
  _ColorPickerFormFieldState createState() => _ColorPickerFormFieldState();
}

class _ColorPickerFormFieldState extends State<ColorPickerFormField> {
  Color selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.labelText), // Changed
        SizedBox(width: 16.0),
        GestureDetector(
          onTap: () {
            _showColorPickerDialog(context);
          },
          child: Container(
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(
              color: selectedColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showColorPickerDialog(BuildContext context) async {
    Color selectedColorCopy = selectedColor;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColorCopy = color;
                });
                widget.onColorChanged(
                    color); // Pass the selected color back to the parent widget
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedColor = selectedColorCopy;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }
}
