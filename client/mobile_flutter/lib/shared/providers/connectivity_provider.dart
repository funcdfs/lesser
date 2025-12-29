import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity state
enum ConnectivityStatus { connected, disconnected, unknown }

/// Connectivity notifier
class ConnectivityNotifier extends Notifier<ConnectivityStatus> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  ConnectivityStatus build() {
    // Check initial connectivity
    Connectivity().checkConnectivity().then(_updateStatus);

    // Listen for changes
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);

    // Cleanup on dispose
    ref.onDispose(() {
      _subscription?.cancel();
    });

    return ConnectivityStatus.unknown;
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      state = ConnectivityStatus.disconnected;
    } else {
      state = ConnectivityStatus.connected;
    }
  }
}

/// Connectivity provider
final connectivityProvider = NotifierProvider<ConnectivityNotifier, ConnectivityStatus>(
  ConnectivityNotifier.new,
);

/// Helper to check if connected
extension ConnectivityStatusX on ConnectivityStatus {
  bool get isConnected => this == ConnectivityStatus.connected;
  bool get isDisconnected => this == ConnectivityStatus.disconnected;
}
