import '../entities/transport_route.dart';
import '../entities/vehicle.dart';

abstract interface class TransportRepository {
  // Vehicle Management
  Future<List<Vehicle>> getVehicles();
  Future<String> addVehicle(Vehicle vehicle);
  Future<void> updateVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String vehicleId);

  // Route Management
  Future<List<TransportRoute>> getRoutes();
  Future<String> addRoute(TransportRoute route);
  Future<void> updateRoute(TransportRoute route);
  Future<void> deleteRoute(String routeId);
}
