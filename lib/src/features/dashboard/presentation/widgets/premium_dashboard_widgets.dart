import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

// --- Placeholder Components ---
// These will be fully implemented as reusable widgets.

class PremiumHeader extends ConsumerWidget {
  const PremiumHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E), // Navy
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },),
              Row(
                children: [
                  IconButton(
                    onPressed: () {}, // Temporary placeholder
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Good Morning 👋',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              user?.displayName ?? 'User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              user?.role.label ?? '',
              style: const TextStyle(color: Color(0xFFFFC107), fontSize: 14), // Golden
            ),
          ),
        ],
      ),
    );
  }
}


class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: List.generate(4, (index) => _buildPlaceholderCard(index)),
    );
  }

  Widget _buildPlaceholderCard(int index) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Center(child: Text('Stat Data')),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('View All', style: TextStyle(color: Color(0xFF1A237E))),
        ],
      ),
    );
  }
}
