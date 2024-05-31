import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConnectionRequestsScreen extends StatefulWidget {
  @override
  _ConnectionRequestsScreenState createState() =>
      _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState extends State<ConnectionRequestsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  List<DocumentSnapshot> _requests = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      await _getRequests();
    }
  }

  Future<void> _getRequests() async {
    QuerySnapshot requestsSnapshot = await _firestore
        .collection('requests')
        .where('liked', isEqualTo: _currentUser!.uid)
        .get();

    setState(() {
      _requests = requestsSnapshot.docs;
    });
  }

  Future<void> _acceptRequest(DocumentSnapshot request) async {
    Map<String, dynamic> requestData =
        request.data() as Map<String, dynamic>? ?? {};
    String likedByUserId =
        requestData['likedBy'] as String? ?? ''; // Liked user ID
    String likedUserId =
        requestData['liked'] as String? ?? ''; // Liking user ID

    try {
      if (likedByUserId.isNotEmpty && likedUserId.isNotEmpty) {
        // Generate unique match names or use specific formats for both users
        String currentUserMatchName =
            'match_${_currentUser!.uid}_$likedByUserId';
        String likedByUserMatchName =
            'match_${likedByUserId}_${_currentUser!.uid}';

        // Create a new document in the "matches" sub-collection for the current user with the generated match name
        await _firestore
            .collection('Users')
            .doc(_currentUser!.uid)
            .collection('matches')
            .doc(currentUserMatchName)
            .set({
          'match_name': currentUserMatchName,
          'user_id': _currentUser!.uid,
          'matched_user_id': likedByUserId,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'accepted',
        });

        // Create a new document in the "matches" sub-collection for the likedBy user with the generated match name
        await _firestore
            .collection('Users')
            .doc(likedByUserId)
            .collection('matches')
            .doc(likedByUserMatchName)
            .set({
          'match_name': likedByUserMatchName,
          'user_id': likedByUserId,
          'matched_user_id': _currentUser!.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'accepted',
        });

        // Delete the request document from the "requests" collection
        await request.reference.delete();

        // Refresh the requests list after accepting
        await _getRequests();

        print('Request accepted successfully.');
      } else {
        print(
            'Error: likedBy or liked field is empty or not found in the request document.');
      }
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  Future<void> _declineRequest(DocumentSnapshot request) async {
    try {
      // Delete the request document from the "requests" collection
      await request.reference.delete();

      // Refresh the requests list after declining
      await _getRequests();
    } catch (e) {
      print('Error declining request: $e');
    }
  }

  Future<void> _showUserPetsDialog(
      BuildContext context, DocumentSnapshot request, String userId) async {
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
          title: Text('Pets of User'),
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
                    Text('Name: ${pet['Name']}',
                        style: TextStyle(fontSize: 18.0)),
                    Text('Breed: ${pet['Breed']}',
                        style: TextStyle(fontSize: 16.0)),
                    Text('Age: ${pet['Age']}',
                        style: TextStyle(fontSize: 16.0)),
                    Text('Gender: ${pet['Gender']}',
                        style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              );
            }).toList(),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _acceptRequest(request),
                  child: Text('Accept'),
                ),
                ElevatedButton(
                  onPressed: () => _declineRequest(request),
                  child: Text('Decline'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestItem(DocumentSnapshot request) {
    Map<String, dynamic> requestData = request.data() as Map<String, dynamic>;
    String likedByUserId = requestData['likedBy'];

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('Users').doc(likedByUserId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Error fetching data');
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;

        return ListTile(
          title: Text(userData[
              'name']), // Assuming 'name' is a field in the user's data
          subtitle: Text('Liked by: ${userData['name']}'),
          onTap: () => _showUserPetsDialog(context, request, likedByUserId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connection Requests'),
      ),
      body: ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          return _buildRequestItem(_requests[index]);
        },
      ),
    );
  }
}
