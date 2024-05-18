import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/login_screen.dart'; 

void main() {
  testWidgets('LoginScreen widgets test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    expect(find.text('Login'), findsWidgets);

    expect(find.byType(TextField), findsNWidgets(2));

    expect(find.byType(ElevatedButton), findsNWidgets(2));

    expect(find.text('FEUP-reUSE'), findsOneWidget);
    expect(
        find.text(
            'FEUP-reUSE helps you share and find reusable resources for a more sustainable world.'),
        findsOneWidget);
  });
  testWidgets('LoginScreen email and password input test', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginScreen()));

  expect(find.text(''), findsNWidgets(2));
  await tester.enterText(find.byType(TextField).first, 'test@example.com');
  await tester.pump();

  expect(find.text('test@example.com'), findsOneWidget);

  await tester.enterText(find.byType(TextField).last, 'password');
  await tester.pump();

  expect(find.text('password'), findsOneWidget);
});

testWidgets('LoginScreen login button test', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginScreen()));

  expect(find.text('Login'), findsOneWidget);

  await tester.tap(find.text('Login'));
  await tester.pump();

  expect(find.text('Login'), findsOneWidget);
});

testWidgets('LoginScreen register button test', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginScreen()));

  await tester.tap(find.text('Register'));
  await tester.pump();

  expect(find.text('Register'), findsOneWidget);
});

testWidgets('LoginScreen Reuse Reduce Recycle text test', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginScreen()));

  expect(find.text('Reuse'), findsOneWidget);
});

}
