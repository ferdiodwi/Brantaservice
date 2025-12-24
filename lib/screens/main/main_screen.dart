import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../home/home_screen.dart';
import '../service/active_service_screen.dart';
import '../history/history_screen.dart';
import '../inventory/inventory_screen.dart';
import '../settings/settings_screen.dart';

// Define icons as const
const List<IconData> _outlinedIcons = [
  Icons.home_outlined,
  Icons.build_outlined,
  Icons.history_outlined,
  Icons.inventory_2_outlined,
  Icons.settings_outlined,
];

const List<IconData> _filledIcons = [
  Icons.home_rounded,
  Icons.build_rounded,
  Icons.history_rounded,
  Icons.inventory_2_rounded,
  Icons.settings_rounded,
];



/// MainScreen - Shell dengan Bottom Navigation yang bisa digeser
class MainScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with AutomaticKeepAliveClientMixin {
  late PageController _pageController;
  int _selectedIndex = 0;
  DateTime? _lastBackPressed;
  
  // Cache screens to prevent rebuilding
  late final List<Widget> _screens;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
    
    // Initialize screens once
    _screens = const [
      HomeScreen(),
      ActiveServiceScreen(),
      HistoryScreen(),
      InventoryScreen(),
      SettingsScreen(),
    ];
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When initialIndex changes (e.g., from navigation), jump to that page
    if (widget.initialIndex != _selectedIndex) {
      _selectedIndex = widget.initialIndex;
      _pageController.jumpToPage(_selectedIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // No-op if same index
    
    setState(() {
      _selectedIndex = index;
    });
    
    // Use jumpToPage for faster navigation, animateToPage for smooth
    _pageController.jumpToPage(index);
  }

  static const platform = MethodChannel('app.brantaservice.main/navigation');

  Future<bool> _handleBackButton() async {
    // Ensure this is the top-most route
    if (ModalRoute.of(context)?.isCurrent != true) {
      return false;
    }

    // Jika bukan di home, navigasi ke home
    if (_selectedIndex != 0) {
      _onItemTapped(0);
      return true;
    }
    
    // Check double tap to exit
    final now = DateTime.now();
    if (_lastBackPressed == null || 
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('common_exit_confirm')),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return true; // Consume event (don't exit yet)
    }
    
    // If double tapped within 2 seconds
    try {
      await platform.invokeMethod('moveToBackground');
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error minimizing: ${e.message}')),
        );
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return BackButtonListener(
      onBackButtonPressed: _handleBackButton,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const ClampingScrollPhysics(), // Faster physics
          onPageChanged: (index) {
            if (_selectedIndex != index) {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          children: _screens,
        ),
        bottomNavigationBar: _BottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

/// Separated bottom nav bar widget for better performance
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  
  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), // Pre-computed shadow color
            blurRadius: 16,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomBarCreative(
          items: List.generate(5, (index) {
            // Localization logic inside build
            final l10n = AppLocalizations.of(context)!;
            final titles = [
              l10n.translate('nav_home'),
              l10n.translate('nav_service'),
              l10n.translate('nav_history'),
              l10n.translate('nav_inventory'),
              l10n.translate('nav_settings'),
            ];
            
            return TabItem(
              icon: selectedIndex == index
                  ? _filledIcons[index]
                  : _outlinedIcons[index],
              title: titles[index],
            );
          }),
          backgroundColor: Colors.transparent,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          colorSelected: AppColors.primary,
          indexSelected: selectedIndex,
          onTap: onTap,
          highlightStyle: const HighlightStyle(
            sizeLarge: true,
            background: AppColors.primary,
            color: AppColors.white,
            elevation: 2,
          ),
          pad: 4,
          paddingVertical: 10,
        ),
      ),
    );
  }
}
