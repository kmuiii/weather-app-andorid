import 'package:flutter_test/flutter_test.dart';
import 'package:weatherapp/main.dart';

void main() {
  testWidgets('WeatherApp smoke test', (WidgetTester tester) async {
    // smoke test: verifikasi class WeatherApp tersedia
    expect(WeatherApp, isNotNull);
  });
}
