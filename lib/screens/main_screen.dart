import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'post_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import '../config/shadcn_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const PostScreen(), // Placeholder
    const ChatScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // TODO: Open Create Post modal
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Open Create Post Modal')));
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop / Tablet Layout
        if (constraints.maxWidth >= 640) {
          return Scaffold(
            backgroundColor: ShadcnColors.background,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Navigation Rail
                Container(
                  width: 88, // Fixed width for sidebar
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: ShadcnColors.border),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: ShadcnSpacing.xl),

                      // Nav Items
                      _NavBarItem(
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home,
                        isSelected: _selectedIndex == 0,
                        onTap: () => _onItemTapped(0),
                        isSidebar: true,
                      ),
                      _NavBarItem(
                        icon: Icons.search,
                        selectedIcon: Icons.search,
                        isSelected: _selectedIndex == 1,
                        onTap: () => _onItemTapped(1),
                        isSidebar: true,
                      ),

                      // Create Button (Sidebar style)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: ShadcnSpacing.lg,
                        ),
                        child: GestureDetector(
                          onTap: () => _onItemTapped(2),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: ShadcnColors.foreground,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: ShadcnColors.background,
                              size: 28,
                            ),
                          ),
                        ),
                      ),

                      _NavBarItem(
                        icon: Icons.chat_bubble_outline,
                        selectedIcon: Icons.chat_bubble,
                        isSelected: _selectedIndex == 3,
                        onTap: () => _onItemTapped(3),
                        isSidebar: true,
                      ),
                      _NavBarItem(
                        icon: Icons.person_outline,
                        selectedIcon: Icons.person,
                        isSelected: _selectedIndex == 4,
                        onTap: () => _onItemTapped(4),
                        isSidebar: true,
                      ),

                      const Spacer(),
                      // Bottom/Spacer items could go here
                      const SizedBox(height: ShadcnSpacing.xl),
                    ],
                  ),
                ),

                // Main Content Area (Centered)
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 900,
                      ), // Max width for content
                      decoration: BoxDecoration(
                        border: const Border.symmetric(
                          vertical: BorderSide(
                            color: ShadcnColors.border,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: _screens,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile Layout (Bottom Navigation)
        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _screens),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: ShadcnColors.background,
              border: Border(
                top: BorderSide(color: ShadcnColors.border, width: 1.0),
              ),
            ),
            padding: const EdgeInsets.only(
              top: ShadcnSpacing.sm,
              bottom: ShadcnSpacing.xl2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onItemTapped(0),
                ),
                _NavBarItem(
                  icon: Icons.search,
                  selectedIcon: Icons.search,
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),
                // Central Add Button
                GestureDetector(
                  onTap: () => _onItemTapped(2),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ShadcnColors.foreground,
                      borderRadius: BorderRadius.circular(ShadcnRadius.lg),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: ShadcnColors.background,
                      size: 24,
                    ),
                  ),
                ),
                _NavBarItem(
                  icon: Icons.chat_bubble_outline,
                  selectedIcon: Icons.chat_bubble,
                  isSelected: _selectedIndex == 3,
                  onTap: () => _onItemTapped(3),
                ),
                _NavBarItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  isSelected: _selectedIndex == 4,
                  onTap: () => _onItemTapped(4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSidebar;

  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
    this.isSidebar = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: isSidebar
            ? const EdgeInsets.symmetric(vertical: ShadcnSpacing.lg)
            : const EdgeInsets.all(ShadcnSpacing.sm),
        child: Icon(
          isSelected ? selectedIcon : icon,
          size: 28, // Slightly larger icons
          color: isSelected
              ? ShadcnColors.foreground
              : ShadcnColors.mutedForeground,
        ),
      ),
    );
  }
}
