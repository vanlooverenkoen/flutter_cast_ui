import 'package:flutter/cupertino.dart';

mixin DisposeMixin on ChangeNotifier {
  var _disposed = false;

  bool get disposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
