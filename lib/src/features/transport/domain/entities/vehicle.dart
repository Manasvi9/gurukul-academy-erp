enum VehicleType {
  bus('bus', 'Bus'),
  van('van', 'Van');

  const VehicleType(this.value, this.label);
  final String value;
  final String label;

  static VehicleType fromValue(String value) =>
      VehicleType.values.firstWhere((e) => e.value == value);
}

enum VehicleStatus {
  active('active', 'Active'),
  inactive('inactive', 'Inactive');

  const VehicleStatus(this.value, this.label);
  final String value;
  final String label;

  static VehicleStatus fromValue(String value) =>
      VehicleStatus.values.firstWhere((e) => e.value == value);
}

class Vehicle {
  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.driverName,
    required this.driverPhone,
    required this.capacity,
    required this.status,
  });

  final String id;
  final String vehicleNumber;
  final VehicleType vehicleType;
  final String driverName;
  final String driverPhone;
  final int capacity;
  final VehicleStatus status;
}
