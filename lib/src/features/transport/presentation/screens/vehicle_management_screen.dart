import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../transport_providers.dart';

class VehicleManagementScreen extends ConsumerWidget {
  const VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Management')),
      body: ResponsivePage(
        maxWidth: 800,
        child: AppAsyncView(
          value: vehiclesAsync,
          data: (vehicles) {
            return ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return Card(
                  margin: const EdgeInsets.all(AppSpacing.sm),
                  child: ListTile(
                    title: Text(vehicle.vehicleNumber),
                    subtitle: Text('${vehicle.vehicleType.label} - Driver: ${vehicle.driverName}'),
                    trailing: Text(vehicle.status.label),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
