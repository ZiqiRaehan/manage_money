import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const BottomNav({required this.currentIndex, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF6C5CE7),
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up_rounded),
          label: 'Pendapatan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_down_rounded),
          label: 'Pengeluaran',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
