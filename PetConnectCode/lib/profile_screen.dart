import 'package:csvpro/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('No user found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('Users').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('No user data found.');
                } else {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  return Column(
                    children: [
                      Text('Name: ${userData['name']}'),
                      Text('Email: ${userData['email']}'),
                      SizedBox(height: 20),
                      Text('Pets:', style: TextStyle(fontSize: 18)),
                    ],
                  );
                }
              },
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('Users')
                    .doc(user.uid)
                    .collection('pets')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No pets found.'));
                  } else {
                    var pets = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        var pet = pets[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text('Name: ${pet['Name']}'),
                          subtitle: Text(
                              'Age: ${pet['Age']}, Gender: ${pet['Gender']}, Breed: ${pet['Breed']}'),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPage()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
