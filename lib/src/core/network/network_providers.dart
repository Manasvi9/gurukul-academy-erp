import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_monitor.dart';
import 'network_status.dart';

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkMonitorProvider = Provider<NetworkMonitor>((ref) {
  return ConnectivityNetworkMonitor(ref.watch(connectivityProvider));
});

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  return ref.watch(networkMonitorProvider).watchStatus();
});
