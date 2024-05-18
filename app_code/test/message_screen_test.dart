import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feup_re_use/message_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';

void main() {
  testWidgets('MessageScreen widgets test', (WidgetTester tester) async {
    final fakeFirestore = FakeFirebaseFirestore();

    await fakeFirestore.collection('publications').add({
      'userId': 'testUserId',
      'publicationImageUrl': 'testImageUrl',
      'title': 'Test Publication',
    });

    await tester.pumpWidget(MaterialApp(home: MessageScreen()));

    expect(find.text('FEUP-reUSE'), findsOneWidget);

    expect(find.byType(ListTile), findsNothing);

    expect(find.byType(BottomAppBar), findsOneWidget);
  });
}
