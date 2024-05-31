import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart'; // Ensure you have this import

class MatchScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;
    final String currentUserId = currentUser != null ? currentUser.uid : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Matched Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Users')
            .doc(currentUserId)
            .collection('matches')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> matches = snapshot.data!.docs;

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              String matchedUserId =
                  matches[index]['matched_user_id'] as String? ?? '';
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('Users').doc(matchedUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  String matchName =
                      userSnapshot.data!['name'] as String? ?? 'Unknown';
                  String chatRoomId =
                      _getChatRoomId(currentUserId, matchedUserId);

                  return StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chatRooms')
                        .doc(chatRoomId)
                        .collection('messages')
                        .where('read', isEqualTo: false)
                        .where('senderId', isEqualTo: matchedUserId)
                        .snapshots(),
                    builder: (context, messageSnapshot) {
                      bool hasUnreadMessages = messageSnapshot.hasData &&
                          messageSnapshot.data!.docs.isNotEmpty;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  currentUserId: currentUserId,
                                  matchedUserId: matchedUserId,
                                  chatRoomName: matchName,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                matchName,
                                style: TextStyle(fontSize: 36.0),
                              ),
                              if (hasUnreadMessages)
                                Text(
                                  'New message!',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 14.0),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _getChatRoomId(String userId1, String userId2) {
    List<String> sortedUserIds = [userId1, userId2]..sort();
    return 'chat_${sortedUserIds[0]}_${sortedUserIds[1]}';
  }
}
