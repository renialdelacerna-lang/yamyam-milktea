// This is a basic Flutter widget test for the Yamyam Milk Tea app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_final_inventory/main.dart';
import 'package:flutter_final_inventory/services/database_service.dart';

void main() {
  testWidgets('App initializes and displays home screen', (WidgetTester tester) async {
    // Initialize database service
    final databaseService = DatabaseService();
    await databaseService.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(YamyamApp(databaseService: databaseService));

    // Verify that the home screen is displayed
    expect(find.text('Yamyam Milk Tea'), findsOneWidget);
    expect(find.text('Welcome!'), findsOneWidget);
  });
}

