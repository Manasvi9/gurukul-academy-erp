import 'package:connectivity_plus/connectivity_plus.dart';

import 'network_status.dart';

abstract interface class NetworkMonitor {
  Future<NetworkStatus> currentStatus();

  Stream<NetworkStatus> watchStatus();
}

final class ConnectivityNetworkMonitor implements NetworkMonitor {
  ConnectivityNetworkMonitor(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<NetworkStatus> currentStatus() async {
    final results = await _connectivity.checkConnectivity();
    return _toStatus(results);
  }

  @override
  Stream<NetworkStatus> watchStatus() {
    return _connectivity.onConnectivityChanged.map(_toStatus).distinct();
  }

  NetworkStatus _toStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }
    return NetworkStatus.online;
  }
}
