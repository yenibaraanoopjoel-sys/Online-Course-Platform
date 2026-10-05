import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../core/constants/app_colors.dart';

class StudentShell extends StatefulWidget {
  final Widget child;

  const StudentShell({super.key, required this.child});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home, route: AppRoutes.studentDashboard),
    _NavItem(label: 'Browse', icon: Icons.explore_outlined, activeIcon: Icons.explore, route: AppRoutes.browse),
    _NavItem(label: 'My Courses', icon: Icons.book_outlined, activeIcon: Icons.book, route: AppRoutes.myCourses),
    _NavItem(label: 'Profile', icon: Icons.person_outline, activeIcon: Icons.person, route: AppRoutes.studentProfile),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    context.go(_navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(context),
            const VerticalDivider(width: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Container(
      width: 240,
      color: AppColors.surface,
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.school, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'EduPlatform',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          // Nav items
          ...List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final selected = _selectedIndex == i;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: ListTile(
                leading: Icon(
                  selected ? item.activeIcon : item.icon,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                tileColor: selected ? AppColors.primaryContainer : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onTap: () => _onItemTapped(i),
              ),
            );
          }),
          const Spacer(),
          const Divider(height: 1),
          // User info + logout
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: (auth.currentUser?.profileImage.isNotEmpty ?? false)
                    ? NetworkImage(auth.currentUser!.profileImage)
                    : null,
                child: (auth.currentUser?.profileImage.isEmpty ?? true)
                    ? Text(
                        (auth.currentUser?.fullName.isNotEmpty ?? false)
                            ? auth.currentUser!.fullName[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              title: Text(
                auth.currentUser?.fullName ?? 'Student',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: const Text(
                'Student',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.logout, size: 18, color: AppColors.textSecondary),
                onPressed: () async {
                  await context.read<AuthService>().logout();
                  if (context.mounted) context.go(AppRoutes.login);
                },
                tooltip: 'Logout',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}
