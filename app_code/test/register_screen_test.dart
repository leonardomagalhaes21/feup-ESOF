import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import '../lib/register_screen.dart'; 

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  testWidgets('RegisterScreen widgets test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));

    expect(find.byType(TextField), findsNWidgets(4));

    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
