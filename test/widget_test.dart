// ResQLink Widget Tests
// Basic tests for the ResQLink emergency communication app

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('ResQLink app launches successfully', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ResQLink());

    // Verify that ResQLink title appears
    expect(find.text('ResQLink'), findsWidgets);

    // Verify that SOS button exists
    expect(find.text('SOS'), findsOneWidget);
  });

  testWidgets('Main screen shows network status', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ResQLink());

    // Verify network status indicator exists
    expect(find.text('Network Status'), findsOneWidget);
  });
}
