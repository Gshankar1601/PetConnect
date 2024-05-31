import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchedUsersScreen extends StatefulWidget {
  @override
  _MatchedUsersScreenState createState() => _MatchedUsersScreenState();
}

class _MatchedUsersScreenState extends State<MatchedUsersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  List<DocumentSnapshot> _matches = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      await _getMatches();
    }
  }

  Future<void> _getMatches() async {
    QuerySnapshot matchesSnapshot = await _firestore
        .collection('Users')
        .doc(_currentUser!.uid)
        .collection('matches')
        .get();

    setState(() {
      _matches = matchesSnapshot.docs;
    });
  }

  Widget _buildMatchItem(DocumentSnapshot match) {
    Map<String, dynamic> matchData = match.data() as Map<String, dynamic>;
    String matchedUserId = matchData['matched_user_id'] ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('Users').doc(matchedUserId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text('Loading...'),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return ListTile(
            title: Text('Error fetching data'),
          );
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};
        String userName = userData['name'] ?? 'Unknown User';

        return ListTile(
          title: Text('$userName'),
          onTap: () => _showMatchedUserPets(context, matchedUserId, userName),
        );
      },
    );
  }

  Future<void> _showMatchedUserPets(
      BuildContext context, String userId, String userName) async {
    QuerySnapshot petsSnapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('pets')
        .get();

    List<Map<String, dynamic>> pets = petsSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$userName's pets"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: pets.map((pet) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 5.0),
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${pet['Name'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 18.0)),
                    Text('Breed: ${pet['Breed'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 16.0)),
                    Text('Age: ${pet['Age'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 16.0)),
                    Text('Gender: ${pet['Gender'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matched Users'),
      ),
      body: ListView.builder(
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          return _buildMatchItem(_matches[index]);
        },
      ),
    );
  }
}
