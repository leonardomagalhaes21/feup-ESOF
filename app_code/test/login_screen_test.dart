import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/login_screen.dart'; // Update with the correct path

void main() {
  testWidgets('LoginScreen widgets test', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    // Verify that the LoginScreen title is rendered.
    expect(find.text('Login'), findsWidgets);

    // Verify that the LoginScreen has text fields for email and password.
    expect(find.byType(TextField), findsNWidgets(2));

    // Verify that the LoginScreen has two ElevatedButtons for login and register.
    expect(find.byType(ElevatedButton), findsNWidgets(2));

    // Verify that the LoginScreen has the description text widgets.
    expect(find.text('FEUP-reUSE'), findsOneWidget);
    expect(find.text('O FEUP-reUSE ajuda-te a partilhar e encontrar recursos reutilizáveis para um mundo mais sustentável.'), findsOneWidget);
  });
}
