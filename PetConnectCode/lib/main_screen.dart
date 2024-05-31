import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'app_bar.dart';
import 'pet_list.dart';
import 'reminder_list.dart';
import 'bloghomepage.dart';
import 'connect.dart';
import 'groominginput.dart';
import 'healthinput.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkReminders();
  }

  Future<void> _checkReminders() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final remindersSnapshot = await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('Reminders')
        .get();

    final now = DateTime.now();
    for (var doc in remindersSnapshot.docs) {
      var reminder = doc.data();
      Timestamp timestamp = reminder['DateTime'];
      DateTime reminderDate = timestamp.toDate();
      if (now.year == reminderDate.year &&
          now.month == reminderDate.month &&
          now.day == reminderDate.day) {
        _showNotification(reminder['Title'], reminderDate);
      }
    }
  }

  void _showNotification(String title, DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reminder'),
          content: Text(
              'Reminder: $title\nDate: ${DateFormat.yMMMd().add_jm().format(date)}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(auth: _auth),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PetList(auth: _auth, firestore: _firestore),
            SizedBox(height: 20),
            ReminderList(auth: _auth, firestore: _firestore),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildButton(
                  context,
                  'assets/pills1.png',
                  'Health',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HealthInputScreen()),
                    );
                  },
                ),
                buildButton(
                  context,
                  'assets/scissors1.png',
                  'Grooming',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GroomingInputScreen()),
                    );
                  },
                ),
                buildButton(
                  context,
                  'assets/heartnpaw.png',
                  'Connect',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Connect()),
                    );
                  },
                ),
                buildButton(
                  context,
                  'assets/blog1.png',
                  'Blog',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BlogListScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, String assetPath, String label,
      VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            assetPath,
            height: 50,
            width: 50,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
