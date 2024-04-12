import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublicationItem extends StatelessWidget {
  final QueryDocumentSnapshot publication;

  const PublicationItem({Key? key, required this.publication})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
        future: getUserDetails(publication['userId']),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          var user = snapshot.data!;
          var userName = user['name'] ?? 'Unknown';
          var profileImageUrl = user['profileImageUrl'] ?? '';
          var timestamp = DateFormat('yyyy-MM-dd HH:mm')
              .format(publication['timestamp'].toDate());
          var publicationImageUrl = publication['publicationImageUrl'] ?? '';
          var description = publication['description'] ?? '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName),
                      Text(
                        timestamp,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              FutureBuilder(
                future: decodeImage(publicationImageUrl),
                builder:
                    (context, AsyncSnapshot<ImageProvider?> imageSnapshot) {
                  if (imageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  return Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageSnapshot.data ??
                            AssetImage('assets/placeholder_image.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 8),
              Text(description),
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
