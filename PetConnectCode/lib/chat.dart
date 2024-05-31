import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String matchedUserId;
  final String chatRoomName;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.matchedUserId,
    required this.chatRoomName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoomName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatRooms')
                  .doc(_getChatRoomId())
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<DocumentSnapshot> messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> messageData =
                        messages[index].data() as Map<String, dynamic>;
                    String message = messageData['message'];
                    String senderId = messageData['senderId'];
                    Timestamp timestamp = messageData['timestamp'] as Timestamp;
                    bool isSentByCurrentUser = senderId == widget.currentUserId;

                    String formattedTime =
                        DateFormat('hh:mm a').format(timestamp.toDate());

                    return Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      alignment: isSentByCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSentByCurrentUser
                              ? Colors.blue[100]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: isSentByCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getChatRoomId() {
    List<String> sortedUserIds = [widget.currentUserId, widget.matchedUserId]
      ..sort();
    return 'chat_${sortedUserIds[0]}_${sortedUserIds[1]}';
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _firestore
          .collection('chatRooms')
          .doc(_getChatRoomId())
          .collection('messages')
          .add({
        'message': message,
        'senderId': widget.currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      _messageController.clear();
    }
  }

  void _markMessagesAsRead() async {
    String chatRoomId = _getChatRoomId();
    QuerySnapshot unreadMessagesSnapshot = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('read', isEqualTo: false)
        .where('senderId', isEqualTo: widget.matchedUserId)
        .get();

    for (DocumentSnapshot doc in unreadMessagesSnapshot.docs) {
      doc.reference.update({'read': true});
    }
  }
}
