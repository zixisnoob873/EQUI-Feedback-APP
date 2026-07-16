import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/field_config_provider.dart';
import 'screens/data_entry_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/fade_scale_route.dart';

class EquilibriumGamingZone extends ConsumerStatefulWidget {
  const EquilibriumGamingZone({super.key});

  @override
  ConsumerState<EquilibriumGamingZone> createState() =>
      _EquilibriumGamingZoneState();
}

class _EquilibriumGamingZoneState extends ConsumerState<EquilibriumGamingZone> {
  int _currentIndex = 0;

  final _screens = const [
    DataEntryScreen(),
    DashboardScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(fieldConfigProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
      child: MaterialApp(
        title: 'Equilibrium Gaming Zone',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _screens[_currentIndex],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/settings':
              return FadeScaleRoute(page: const SettingsScreen());
            default:
              return null;
          }
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.edit_note_rounded),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_note_rounded, color: AppColors.gold),
            ),
            label: 'Entry',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_rounded),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dashboard_rounded, color: AppColors.gold),
            ),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}
