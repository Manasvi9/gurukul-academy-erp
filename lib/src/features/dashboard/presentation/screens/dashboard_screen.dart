import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../widgets/premium_dashboard_widgets.dart';

final class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF5F5F5), // Very Light Grey
      body: ListView(
        children: const [
          PremiumHeader(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                DashboardStatsGrid(),
                SectionHeader(title: "Today's Schedule"),
                // Placeholder for Schedule
                SizedBox(height: 100, child: Center(child: Text("Schedule Placeholder"))),
                SectionHeader(title: "Quick Actions"),
                // Placeholder for Quick Actions
                SizedBox(height: 100, child: Center(child: Text("Actions Placeholder"))),
                SectionHeader(title: "Recent Activity"),
                // Placeholder for Recent Activity
                SizedBox(height: 100, child: Center(child: Text("Activity Placeholder"))),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}