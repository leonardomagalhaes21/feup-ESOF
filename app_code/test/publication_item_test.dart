import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feup_re_use/publication_item.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}

void main() {
  group('PublicationItem Tests', () {


    test('Test decodeImage', () async {
      final imageUrl = 'fake_image_base64_encoded_string';
      final mockSnapshot = MockQueryDocumentSnapshot();
      when(mockSnapshot['publicationImageUrl']).thenReturn(imageUrl);

      final publicationItem = PublicationItem(
        publication: mockSnapshot,
        userRating: 0.0,
      );

      final imageProvider = await publicationItem.decodeImage(imageUrl);

      expect(imageProvider, isNotNull);
    });
  });
}
