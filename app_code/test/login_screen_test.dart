import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/login_screen.dart'; // Update with the correct path

void main() {
  testWidgets('LoginScreen widgets test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    expect(find.text('Login'), findsWidgets);

    expect(find.byType(TextField), findsNWidgets(2));

    expect(find.byType(ElevatedButton), findsNWidgets(2));

    expect(find.text('FEUP-reUSE'), findsOneWidget);
    expect(
        find.text(
            'O FEUP-reUSE ajuda-te a partilhar e encontrar recursos reutilizáveis para um mundo mais sustentável.'),
        findsOneWidget);
  });
}
