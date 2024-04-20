import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class PublicationItem extends StatelessWidget {
  final QueryDocumentSnapshot publication;
  final double userRating;

  const PublicationItem(
      {Key? key, required this.publication, required this.userRating})
      : super(key: key);

  Future<double> getUserRating(String userId) async {
  var doc = await FirebaseFirestore.instance
      .collection('ratings')
      .doc(userId)
      .get();
  double rating = doc.exists ? (doc['rating'] as num?)?.toDouble() ?? 0.0 : 0.0;
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
            return SizedBox();
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(profileImageUrl),
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
                            return Text('$userName Rating: ...');
                          } else {
                            double sellerRating = ratingSnapshot.data!;
                            return Text('$userName Rating: $sellerRating');
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
                    return SizedBox();
                  }
                  double screenWidth = MediaQuery.of(context).size.width;
                  return Image(
                    image: imageSnapshot.data!,
                    width: screenWidth,
                    fit: BoxFit.contain,
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(description),
              const SizedBox(height: 8),
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
    return MemoryImage(Uint8List.fromList(imageBytes));
  }
}