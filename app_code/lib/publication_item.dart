import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import 'chat_screen.dart';

class PublicationItem extends StatelessWidget {
  final QueryDocumentSnapshot publication;
  final double userRating;

  const PublicationItem(
      {super.key, required this.publication, required this.userRating});

  Future<double> getUserRating(String userId) async {
    var doc = await FirebaseFirestore.instance
        .collection('ratings')
        .doc(userId)
        .get();
    double rating =
        doc.exists ? (doc['rating'] as num?)?.toDouble() ?? 0.0 : 0.0;
    return rating;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<DocumentSnapshot>(
        future: getUserDetails(publication['userId']),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          var user = snapshot.data!;
          var userName = user['name'] ?? 'Unknown';
          var profileImageUrl = user['profileImageUrl'] ?? '';
          var timestamp = DateFormat('yyyy-MM-dd HH:mm')
              .format(publication['timestamp'].toDate());
          var publicationImageUrl = publication['publicationImageUrl'] ?? '';
          var description = publication['description'] ?? '';
          var title = publication['title'] ?? '';
          var sellerRatingFuture = getUserRating(user.id);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FutureBuilder<ImageProvider?>(
                    future: decodeImage(profileImageUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                              ConnectionState.waiting ||
                          snapshot.data == null) {
                        return const CircularProgressIndicator();
                      }
                      return CircleAvatar(
                        radius: 20,
                        backgroundImage: snapshot.data!,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<double>(
                        future: sellerRatingFuture,
                        builder:
                            (context, AsyncSnapshot<double> ratingSnapshot) {
                          if (ratingSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                              '$userName                          Rating: ...',
                              overflow: TextOverflow.ellipsis,
                            );
                          } else {
                            double sellerRating = ratingSnapshot.data!;
                            return Text(
                              '$userName                          Rating: $sellerRating',
                              overflow: TextOverflow.ellipsis,
                            );
                          }
                        },
                      ),
                      Text(
                        timestamp,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<ImageProvider?>(
                future: decodeImage(publicationImageUrl),
                builder:
                    (context, AsyncSnapshot<ImageProvider?> imageSnapshot) {
                  if (imageSnapshot.connectionState ==
                          ConnectionState.waiting ||
                      imageSnapshot.data == null) {
                    return const CircularProgressIndicator();
                  }
                  return SizedBox(
                    width: 500,
                    height: 500,
                    child: Image(
                      image: imageSnapshot.data!,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Description: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(description),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (publication['userId'] != FirebaseAuth.instance.currentUser?.uid)
                  ElevatedButton.icon(
                    onPressed: () {
                      String sellerId = publication['userId'];
                      String sellerName = user['name'] ?? 'Unknown';
                      String publicationId = publication.id;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            recipientId: sellerId,
                            recipientName: sellerName,
                            publicationId: publicationId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Chat with Seller'),
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> getUserDetails(String userId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
  }

  Future<ImageProvider?> decodeImage(String imageUrl) async {
    List<int> imageBytes = base64Decode(imageUrl.split(',').last);
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      return null;
    }

    if (originalImage.width > 1920 || originalImage.height > 1080) {
      img.Image resizedImage = img.copyResize(originalImage,
          width: originalImage.width > 1920 ? 1920 : null,
          height: originalImage.height > 1080 ? 1080 : null);
      imageBytes = img.encodePng(resizedImage);
    }

    return MemoryImage(Uint8List.fromList(imageBytes));
  }
}
