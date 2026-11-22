import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingFlagNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) {
    if (state != value) state = value;
  }
}
