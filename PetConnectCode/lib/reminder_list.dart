import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_reminder.dart';
import 'package:intl/intl.dart';

class ReminderList extends StatelessWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  ReminderList({required this.auth, required this.firestore});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reminders:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddReminderPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('Users')
                      .doc(auth.currentUser?.uid)
                      .collection('Reminders')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('No reminders found.'),
                      );
                    } else {
                      var reminders = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: reminders.length,
                        itemBuilder: (context, index) {
                          var reminder =
                              reminders[index].data() as Map<String, dynamic>;
                          final color = _generateLightColor();
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            color: color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              title: Text(reminder['Title']),
                              subtitle: Text(DateFormat.yMMMd().add_jm().format(
                                  (reminder['DateTime'] as Timestamp)
                                      .toDate())),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteReminder(reminders[index].id);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteReminder(String reminderId) async {
    try {
      await firestore
          .collection('Users')
          .doc(auth.currentUser?.uid)
          .collection('Reminders')
          .doc(reminderId)
          .delete();
    } catch (e) {
      print('Failed to delete reminder: $e');
    }
  }

  Color _generateLightColor() {
    final Random random = Random();
    final int r = 230 + random.nextInt(25); // Red component
    final int g = 230 + random.nextInt(25); // Green component
    final int b = 230 + random.nextInt(25); // Blue component
    return Color.fromARGB(255, r, g, b);
  }
}
