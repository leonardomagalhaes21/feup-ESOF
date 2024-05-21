import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'publication_item.dart';

class PublicationList extends StatefulWidget {
  const PublicationList({Key? key}) : super(key: key);

  @override
  _PublicationListState createState() => _PublicationListState();
}

class _PublicationListState extends State<PublicationList> {
  late TextEditingController _searchController;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by title',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
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
                final searchTextLower = _searchText.toLowerCase();
                final List<QueryDocumentSnapshot> filteredDocs = snapshot.data!.docs
                    .where((publication) =>
                        (publication['title'] as String).toLowerCase().contains(searchTextLower))
                    .toList();
                return filteredDocs.isEmpty
                    ? Center(
                        child: Text('No publications found.'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          var publication = filteredDocs[index];
                          return PublicationItem(
                            publication: publication,
                            userRating: 0,
                          );
                        },
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
