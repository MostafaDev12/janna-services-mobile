import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';
import '../categories/categories_screen.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../important_numbers/important_numbers_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    ImportantNumbersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: AppStrings.of(context, 'home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.category_outlined),
            activeIcon: const Icon(Icons.category_rounded),
            label: AppStrings.of(context, 'categories'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border_rounded),
            activeIcon: const Icon(Icons.favorite_rounded),
            label: AppStrings.of(context, 'favorites'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.phone_outlined),
            activeIcon: const Icon(Icons.phone_rounded),
            label: AppStrings.of(context, 'numbers'),
          ),
        ],
      ),
    );
  }
}
