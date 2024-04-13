import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  // Define your list of navigation icons here
  final List<IconData> navIcons = [
    Icons.home_outlined,
    Icons.calendar_month_outlined,
    Icons.notifications_active_outlined,
    Icons.person_2_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navIcons.asMap().entries.map((entry) {
          int idx = entry.key;
          IconData icon = entry.value;
          return _buildNavItem(icon, idx);
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    Color iconColor = widget.selectedIndex == index ? Colors.lightBlue : Colors.grey;
    return IconButton(
      icon: Icon(icon, color: iconColor),
      onPressed: () => widget.onItemSelected(index),
    );
  }
}
