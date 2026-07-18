import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/transport_route.dart';
import '../domain/entities/vehicle.dart';
import '../domain/repositories/transport_repository.dart';

class SupabaseTransportRepository implements TransportRepository {
  SupabaseTransportRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Vehicle>> getVehicles() async {
    final response = await _client.from('vehicles').select();
    return (response as List<dynamic>)
        .map((e) {
          final row = e as Map<String, dynamic>;
          return Vehicle(
            id: row['id'] as String,
            vehicleNumber: row['vehicle_number'] as String,
            vehicleType: VehicleType.fromValue(row['vehicle_type'] as String),
            driverName: row['driver_name'] as String,
            driverPhone: row['driver_phone'] as String,
            capacity: row['capacity'] as int,
            status: VehicleStatus.fromValue(row['status'] as String),
          );
        },)
        .toList();
  }

  @override
  Future<String> addVehicle(Vehicle vehicle) async {
    final response = await _client
        .from('vehicles')
        .insert({
          'vehicle_number': vehicle.vehicleNumber,
          'vehicle_type': vehicle.vehicleType.value,
          'driver_name': vehicle.driverName,
          'driver_phone': vehicle.driverPhone,
          'capacity': vehicle.capacity,
          'status': vehicle.status.value,
        })
        .select('id')
        .single();
    return response['id'] as String;
  }

  @override
  Future<void> updateVehicle(Vehicle vehicle) async {
    await _client.from('vehicles').update({
      'vehicle_number': vehicle.vehicleNumber,
      'vehicle_type': vehicle.vehicleType.value,
      'driver_name': vehicle.driverName,
      'driver_phone': vehicle.driverPhone,
      'capacity': vehicle.capacity,
      'status': vehicle.status.value,
    }).eq('id', vehicle.id);
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    await _client.from('vehicles').delete().eq('id', vehicleId);
  }

  @override
  Future<List<TransportRoute>> getRoutes() async {
    final response = await _client.from('transport_routes').select('*, route_stops(*)');
    return (response as List<dynamic>).map((e) {
      final routeMap = e as Map<String, dynamic>;
      final stops = (routeMap['route_stops'] as List<dynamic>).map((s) {
        final stopMap = s as Map<String, dynamic>;
        return RouteStop(
          stopName: stopMap['stop_name'] as String,
          pickupTime: _parseTime(stopMap['pickup_time'] as String),
          dropTime: _parseTime(stopMap['drop_time'] as String),
          stopOrder: stopMap['stop_order'] as int,
        );
      }).toList();
      return TransportRoute(
        id: routeMap['id'] as String,
        routeName: routeMap['route_name'] as String,
        stops: stops,
      );
    }).toList();
  }

  @override
  Future<String> addRoute(TransportRoute route) async {
    final response = await _client
        .from('transport_routes')
        .insert({'route_name': route.routeName})
        .select('id')
        .single();
    final routeId = response['id'] as String;
    
    for (final stop in route.stops) {
      await _client.from('route_stops').insert({
        'route_id': routeId,
        'stop_name': stop.stopName,
        'pickup_time': _formatTime(stop.pickupTime),
        'drop_time': _formatTime(stop.dropTime),
        'stop_order': stop.stopOrder,
      });
    }
    return routeId;
  }

  @override
  Future<void> updateRoute(TransportRoute route) async {
    await _client.from('transport_routes').update({'route_name': route.routeName}).eq('id', route.id);
    
    await _client.from('route_stops').delete().eq('route_id', route.id);
    for (final stop in route.stops) {
      await _client.from('route_stops').insert({
        'route_id': route.id,
        'stop_name': stop.stopName,
        'pickup_time': _formatTime(stop.pickupTime),
        'drop_time': _formatTime(stop.dropTime),
        'stop_order': stop.stopOrder,
      });
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  @override
  Future<void> deleteRoute(String routeId) async {
    await _client.from('transport_routes').delete().eq('id', routeId);
  }
}
