import 'package:flutter/material.dart';
import 'home/beranda.dart';
import 'home/progress.dart';
import 'home/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    BerandaPage(),
    ProgressPage(),
    ProfilePage(),
  ];

  static const Color _background = Color(0xFF0B0F12);
  static const Color _navBackground = Color(0xFF151B20);
  static const Color _green = Color(0xFF62E6A2);

  static const _navigationItems = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Beranda'),
    (
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: 'Progress',
    ),
    (icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: _navBackground,
          indicatorColor: _green.withOpacity(0.18),
          elevation: 0,
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: _green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              );
            }

            return const TextStyle(color: Colors.white54, fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: _green, size: 25);
            }

            return const IconThemeData(color: Colors.white54, size: 23);
          }),
        ),
        child: NavigationBar(
          backgroundColor: _navBackground,
          selectedIndex: _selectedIndex,
          elevation: 0,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: [
            for (final item in _navigationItems)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}
