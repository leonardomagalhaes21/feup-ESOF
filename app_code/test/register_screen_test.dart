import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import '../lib/register_screen.dart'; // Update with the correct path

// Mock FirebaseAuth for testing
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  testWidgets('RegisterScreen widgets test', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));

    // Verify that the RegisterScreen has text fields for name, email, password, and confirm password.
    expect(find.byType(TextField), findsNWidgets(4));

    // Verify that the RegisterScreen has an ElevatedButton.
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
