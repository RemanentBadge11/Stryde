import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class NetworkConnectivity {
  Future<bool> get isOnline;
  Stream<bool> get onConnectivityChanged;
}

class MemoryNetworkConnectivity implements NetworkConnectivity {
  MemoryNetworkConnectivity({bool initialOnline = true})
    : _isOnline = initialOnline;

  bool _isOnline;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> get isOnline async => _isOnline;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void setOnline(bool online) {
    _isOnline = online;
    _controller.add(online);
  }

  void dispose() {
    _controller.close();
  }
}

class PlusNetworkConnectivity implements NetworkConnectivity {
  PlusNetworkConnectivity([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> get isOnline async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
}

final networkConnectivityProvider = Provider<NetworkConnectivity>((ref) {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    final connectivity = MemoryNetworkConnectivity();
    ref.onDispose(() => connectivity.dispose());
    return connectivity;
  }
  return PlusNetworkConnectivity();
});
