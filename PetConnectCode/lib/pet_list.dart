import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_pet_page.dart';

class PetList extends StatelessWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  PetList({required this.auth, required this.firestore});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Pets:',
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
                        builder: (context) => AddPetPage(),
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
                    .collection('pets')
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
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No pets found.'),
                    );
                  } else {
                    var pets = snapshot.data!.docs;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        var pet = pets[index].data() as Map<String, dynamic>;
                        final color = _generateLightColor();
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (pet['ImageUrl'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                    child: Image.network(
                                      pet['ImageUrl'],
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet['Name'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Age: ${pet['Age']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Gender: ${pet['Gender']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Breed: ${pet['Breed']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Pet Type: ${pet['PetType']}', // Display pet type
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
    );
  }

  Color _generateLightColor() {
    final List<Color> colors = [
      Color(0xFFFF76CE),
      Color(0xFFFDFFC2),
      Color(0xFF94FFD8),
      Color(0xFFA3D8FF),
      Color(0xFFC4FF64),
      Color(0xFF9CFFFB),
      Color(0xFFFFD666),
      Color(0xFFBAFF64),
      Color(0xFFFF8C64),
      Color(0xFFFF64AA),
    ];
    final Random random = Random();
    return colors[random.nextInt(colors.length)];
  }
}
