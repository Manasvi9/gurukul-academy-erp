import 'package:flutter/material.dart';

class RouteStop {
  const RouteStop({
    required this.stopName,
    required this.pickupTime,
    required this.dropTime,
    required this.stopOrder,
  });

  final String stopName;
  final TimeOfDay pickupTime;
  final TimeOfDay dropTime;
  final int stopOrder;
}

class TransportRoute {
  const TransportRoute({
    required this.id,
    required this.routeName,
    required this.stops,
  });

  final String id;
  final String routeName;
  final List<RouteStop> stops;
}
