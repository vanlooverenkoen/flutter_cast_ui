import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cast_ui/cast_ui.dart';

void main() {
  const channel = MethodChannel('cast_ui');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await CastUi.platformVersion, '42');
  });
}
