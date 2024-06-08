import 'package:flutter/material.dart';
import 'schedule_preferences.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _loadSelectedColor();
  }

  Future<void> _loadSelectedColor() async {
    final Color? selectedColor =
        await SchedulePreferences().loadSelectedColor();
    if (selectedColor != null) {
      setState(() {
        _selectedColor = selectedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kBottomNavigationBarHeight, // Fixed height to prevent jumping
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: (index) {
          widget.onTap(index);
        },
        backgroundColor: _selectedColor, // Set background color dynamically
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadSelectedColor();
  }
}
