import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feup_re_use/search_screen.dart';

void main() {
  testWidgets('SearchScreen widgets test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SearchScreen()));

    expect(find.text('FEUP-reUSE'), findsOneWidget);

    expect(find.byType(TextField), findsOneWidget);

    await tester.pump();

    expect(find.byType(ListTile), findsNothing);

    expect(find.byType(BottomAppBar), findsOneWidget);
  });
}
