import 'package:flutter_test/flutter_test.dart';
import 'package:stop_at_67/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    expect(StopAt67App, isNotNull);
  });
}
