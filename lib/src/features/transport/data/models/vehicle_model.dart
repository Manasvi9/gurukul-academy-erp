import '../../domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.vehicleNumber,
    required super.vehicleType,
    required super.driverName,
    required super.driverPhone,
    required super.capacity,
    required super.status,
  });

  factory VehicleModel.fromJson(Map<String, Object?> json) {
    return VehicleModel(
      id: json['id'] as String,
      vehicleNumber: json['vehicle_number'] as String,
      vehicleType: VehicleType.fromValue(json['vehicle_type'] as String),
      driverName: json['driver_name'] as String,
      driverPhone: json['driver_phone'] as String,
      capacity: json['capacity'] as int,
      status: VehicleStatus.fromValue(json['status'] as String),
    );
  }
}
