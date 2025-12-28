import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity state
enum ConnectivityStatus { connected, disconnected, unknown }

/// Connectivity notifier
class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityNotifier() : super(ConnectivityStatus.unknown) {
    _init();
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void _init() {
    // Check initial connectivity
    Connectivity().checkConnectivity().then(_updateStatus);

    // Listen for changes
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      state = ConnectivityStatus.disconnected;
    } else {
      state = ConnectivityStatus.connected;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Connectivity provider
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});

/// Helper to check if connected
extension ConnectivityStatusX on ConnectivityStatus {
  bool get isConnected => this == ConnectivityStatus.connected;
  bool get isDisconnected => this == ConnectivityStatus.disconnected;
}
