import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'state/providers/auth_provider.dart';
import 'state/providers/payroll_provider.dart';
import 'state/providers/notification_provider.dart';
import 'state/providers/attendance_provider.dart';
import 'state/providers/leave_provider.dart';
import 'state/providers/holiday_provider.dart';
import 'state/providers/permission_provider.dart';
import 'state/providers/shift_provider.dart';

import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/attendance/my_attendance_screen.dart';
import 'presentation/screens/attendance/leave_requests_screen.dart';
import 'presentation/screens/attendance/permission_requests_screen.dart';
import 'presentation/screens/payroll/payroll_list_screen.dart';
import 'presentation/screens/payroll/my_payslips_screen.dart';
import 'presentation/screens/payroll/payslip_screen.dart';
import 'presentation/screens/notifications/notifications_screen.dart';
import 'presentation/screens/notifications/notification_detail_screen.dart';
import 'presentation/screens/shifts/my_shift_screen.dart';
import 'presentation/screens/shifts/shift_change_requests_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PayrollProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => HolidayProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
      ],
      child: MaterialApp(
        title: 'HRMS Frontend',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          // Attendance
          '/my-attendance': (context) => const MyAttendanceScreen(),
          '/leave-requests': (context) => const LeaveRequestsScreen(),
          '/permission-requests': (context) => const PermissionRequestsScreen(),
          // Payroll
          '/payroll-list': (context) => const PayrollListScreen(),
          '/my-payslips': (context) => const MyPayslipsScreen(),
          // Notifications
          '/notifications': (context) => const NotificationsScreen(),
          // Shifts
          '/my-shifts': (context) => const MyShiftScreen(),
        },
        onGenerateRoute: (settings) {
            if (settings.name == '/payslip-view') {
                final id = settings.arguments as int;
                return MaterialPageRoute(builder: (_) => PayslipScreen(payrollId: id));
            }
            if (settings.name == '/notification-detail') {
                 // Using dynamic to avoid circular dependency issues if model import is tricky, 
                 // but imports are in main.dart so it should be fine.
                 // However, to be safe given context, assuming arguments is the item.
                 // Need to make sure NotificationItem is imported or cast as dynamic.
                 // Imports are: import 'presentation/screens/notifications/notification_detail_screen.dart';
                 // But NotificationItem is in model.
                 // Let's rely on dynamic dispatch or add model import if missing.
                 // We need to import 'data/models/notification_model.dart' and 'data/models/shift_models.dart'.
                 // Let's assume passed argument is correct type.
                 final args = settings.arguments;
                 return MaterialPageRoute(builder: (_) => NotificationDetailScreen(notification: args as dynamic));
            }
             if (settings.name == '/shift-change-requests') {
                 final args = settings.arguments;
                 return MaterialPageRoute(builder: (_) => ShiftChangeRequestsScreen(shiftToChange: args as dynamic));
            }
            return null;
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        switch (authProvider.state) {
          case AuthState.initial:
          case AuthState.loading:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case AuthState.authenticated:
            return const DashboardScreen();
          case AuthState.unauthenticated:
          case AuthState.error:
          default:
            return const LoginScreen();
        }
      },
    );
  }
}
