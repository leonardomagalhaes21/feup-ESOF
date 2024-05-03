import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_test/flutter_test.dart';

test('uploadImage from gallery sets _publicationImageUrl', () async {
  // Mock ImagePicker to return a valid image
  final mockImagePicker = MockImagePicker();
  when(mockImagePicker.pickImage(source: ImageSource.gallery)).thenAnswer((_) => Future.value(XFile('path/to/image.jpg')));

  // Replace the real ImagePicker with the mock
  final addPublicationScreen = AddPublicationScreen();
  addPublicationScreen._imagePicker = mockImagePicker;

  await addPublicationScreen.uploadImage(ImageSource.gallery);

  expect(addPublicationScreen._publicationImageUrl, isNotEmpty);
  verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
});

test('uploadImage from camera sets _publicationImageUrl', () async {
  // Mock ImagePicker to return a valid image
  final mockImagePicker = MockImagePicker();
  when(mockImagePicker.pickImage(source: ImageSource.camera)).thenAnswer((_) => Future.value(XFile('path/to/image.jpg')));

  // Replace the real ImagePicker with the mock
  final addPublicationScreen = AddPublicationScreen();
  addPublicationScreen._imagePicker = mockImagePicker;

  await addPublicationScreen.uploadImage(ImageSource.camera);

  expect(addPublicationScreen._publicationImageUrl, isNotEmpty);
  verify(mockImagePicker.pickImage(source: ImageSource.camera)).called(1);
});

test('uploadPublication with image uploads data to firestore', () async {
  // Mock FirebaseFirestore to simulate successful upload
  final mockFirestore = MockFirebaseFirestore();
  final mockCollectionRef = MockCollectionReference();
  final mockDocumentRef = MockDocumentReference();

  when(mockFirestore.collection('publications')).thenReturn(mockCollectionRef);
  when(mockCollectionRef.add(any)).thenReturn(Future.value(mockDocumentRef));

  // Replace the real Firestore instance with the mock
  final addPublicationScreen = AddPublicationScreen();
  addPublicationScreen._auth = MockFirebaseAuth();
  // Inject the mock firestore
  // ... (injection logic)

  // Set image and description
  addPublicationScreen._publicationImageUrl = 'data:image/jpeg;base64,...';
  addPublicationScreen._titleController.text = 'Test Title';
  addPublicationScreen._descriptionController.text = 'Test Description';

  await addPublicationScreen.uploadPublication();

  verify(mockCollectionRef.add({
    'title': 'Test Title',
    'description': 'Test Description',
    'publicationImageUrl': 'data:image/jpeg;base64,...',
    'userId': any,
    'timestamp': FieldValue.serverTimestamp(),
  })).called(1);
});

test('uploadPublication without image shows error message', () async {
  final addPublicationScreen = AddPublicationScreen();

  // Set description only
  addPublicationScreen._titleController.text = 'Test Title';
  addPublicationScreen._descriptionController.text = 'Test Description';

  await addPublicationScreen.uploadPublication();

  // Verify print output (assuming print is used for logging)
  expect(debugPrintOutput.contains('Please select an image first.'), true);
});
