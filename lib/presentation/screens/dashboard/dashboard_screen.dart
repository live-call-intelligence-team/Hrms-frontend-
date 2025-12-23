import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../learning/courses_list_screen.dart';
import '../recruitment/job_postings_screen.dart';
import '../recruitment/job_descriptions_screen.dart';
import '../recruitment/candidates_list_screen.dart';
import '../notifications/notifications_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final org = authProvider.organization;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                },
              ),
              PopupMenuButton(
                icon: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    user?.firstName[0].toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                itemBuilder: (context) => <PopupMenuEntry>[
                  const PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.settings_outlined),
                      title: Text('Settings'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    onTap: () => authProvider.logout(),
                    child: const ListTile(
                      leading: Icon(Icons.logout, color: AppTheme.errorColor),
                      title:
                          Text('Logout', style: TextStyle(color: AppTheme.errorColor)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          drawer: _buildDrawer(context, authProvider),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Text(
                  'Welcome back, ${user?.firstName ?? 'User'}!',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                if (org != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    org['name'] ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
                const SizedBox(height: 32),

                // Stats Cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      context,
                      'Employees',
                      org?['usage']?['users']?['current']?.toString() ?? '0',
                      Icons.people_outline,
                      AppTheme.primaryColor,
                    ),
                    _buildStatCard(
                      context,
                      'Branches',
                      org?['usage']?['branches']?['current']?.toString() ?? '0',
                      Icons.business_outlined,
                      AppTheme.secondaryColor,
                    ),
                    _buildStatCard(
                      context,
                      'Attendance Today',
                      '0',
                      Icons.check_circle_outline,
                      AppTheme.successColor,
                    ),
                    _buildStatCard(
                      context,
                      'Leave Requests',
                      '0',
                      Icons.pending_outlined,
                      AppTheme.warningColor,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildQuickAction(context, 'Add Employee', Icons.person_add),
                    _buildQuickAction(context, 'Mark Attendance', Icons.check),
                    _buildQuickAction(context, 'Apply Leave', Icons.event_busy),
                    _buildQuickAction(context, 'View Payroll', Icons.payments),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    final menus = authProvider.menus ?? [];
    
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.business,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  authProvider.user?.fullName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  authProvider.user?.roleName ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard_outlined),
                  title: const Text('Dashboard'),
                  selected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                if (menus.isNotEmpty)
                  ...menus.map((menu) {
                    final children = menu['children'] as List<dynamic>? ?? [];
                    if (children.isNotEmpty) {
                      return ExpansionTile(
                        leading: Icon(_getMenuIcon(menu['icon'] as String?)),
                        title: Text(menu['display_name'] ?? menu['name'] ?? ''),
                        children: children.map((child) => _buildMenuTile(context, child)).toList(),
                      );
                    }
                    return _buildMenuTile(context, menu);
                  })
                else ...[
                  ListTile(
                    leading: const Icon(Icons.people_outlined),
                    title: const Text('Users'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to users
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.school_outlined),
                    title: const Text('Courses'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CoursesListScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.work_outline),
                    title: const Text('Recruitment'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JobPostingsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Job Descriptions'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JobDescriptionsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Attendance'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to attendance
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, dynamic menu) {
    return ListTile(
      leading: Icon(_getMenuIcon(menu['icon'] as String?)),
      title: Text(menu['display_name'] ?? menu['name'] ?? ''),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (menu['route'] != null && (menu['route'] as String).isNotEmpty) {
           // Handle known routes
           final routeName = menu['route'] as String;
           Navigator.pushNamed(context, routeName);
        } else {
           // Handle menus with children or unknown routes
           if (menu['children'] != null && (menu['children'] as List).isNotEmpty) {
             // For now, we don't have nested expansion implemented in this drawer view
             // You might want to expand this tile or show a submenu
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Please select a sub-menu for ${menu['display_name']}')),
             );
           }
        }
      },
    );
  }

  IconData _getMenuIcon(String? iconName) {
    // Map icon names to IconData
    switch (iconName) {
      case 'people':
        return Icons.people_outlined;
      case 'business':
        return Icons.business_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'work':
        return Icons.work_outline;
      case 'access_time':
        return Icons.access_time;
      default:
        return Icons.menu;
    }
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(title),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
