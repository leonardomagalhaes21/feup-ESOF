import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'publication_item.dart';

class PublicationList extends StatefulWidget {
  const PublicationList({super.key});

  @override
  _PublicationListState createState() => _PublicationListState();
}

class _PublicationListState extends State<PublicationList> {
  late TextEditingController _searchController;
  bool _isSearchBarVisible = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Visibility(
                  visible: _isSearchBarVisible,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by title',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: _filterPublications,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isSearchBarVisible = !_isSearchBarVisible;
                    if (!_isSearchBarVisible) {
                      _searchController.clear();
                      _filterPublications('');
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                child: Text('...'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('publications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No publications found.'),
                );
              }
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('ratings')
                    .get(),
                builder: (context, ratingsSnapshot) {
                  if (ratingsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (ratingsSnapshot.hasError) {
                    return Center(
                        child: Text('Error: ${ratingsSnapshot.error}'));
                  }
                  final Map<String, double> userRatings = {
                    for (final doc in ratingsSnapshot.data!.docs)
                      doc.id: (doc['rating'] ?? 0.0).toDouble(),
                  };

                  final List<QueryDocumentSnapshot> filteredPublications =
                      _getFilteredPublications(snapshot.data!.docs);
                  return ListView.builder(
                    itemCount: filteredPublications.length,
                    itemBuilder: (context, index) {
                      var publication = filteredPublications[index];
                      var userId = publication['userId'];
                      var userRating = userRatings[userId] ?? 0.0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PublicationItem(
                            publication: publication,
                            userRating: userRating,
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _filterPublications(String value) {
    setState(() {});
  }

  List<QueryDocumentSnapshot> _getFilteredPublications(
      List<QueryDocumentSnapshot> publications) {
    final String searchQuery = _searchController.text.toLowerCase();
    return publications
        .where((publication) =>
            publication['title'].toString().toLowerCase().contains(searchQuery))
        .toList();
  }
}
