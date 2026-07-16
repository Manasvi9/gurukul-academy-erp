import '../../domain/entities/transport_village.dart';

final class TransportVillageModel extends TransportVillage {
  const TransportVillageModel({
    required super.id,
    required super.name,
    required super.transportFee,
    required super.isActive,
  });

  factory TransportVillageModel.fromJson(Map<String, Object?> json) {
    return TransportVillageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      transportFee: json['transport_fee'] as num,
      isActive: json['is_active'] as bool,
    );
  }
}
