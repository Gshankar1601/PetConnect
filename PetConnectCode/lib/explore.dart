import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Map<String, dynamic>> pets = [];
  int currentIndex = 0;
  bool isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? selectedBreed;
  String? selectedGender;
  String? selectedPetType; // New property for selected pet type

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No logged in user');
        return;
      }

      String currentUserId = currentUser.uid;

      List<String> matchedUserIds = [];
      QuerySnapshot matchedUsersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .collection('matches')
          .get();

      for (QueryDocumentSnapshot matchDoc in matchedUsersSnapshot.docs) {
        matchedUserIds.add(matchDoc['matched_user_id']);
      }

      QuerySnapshot userQuerySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();

      List<Map<String, dynamic>> loadedPets = [];

      for (QueryDocumentSnapshot userDoc in userQuerySnapshot.docs) {
        if (userDoc.id != currentUserId &&
            !matchedUserIds.contains(userDoc.id)) {
          QuerySnapshot petsSnapshot =
              await userDoc.reference.collection('pets').get();
          for (QueryDocumentSnapshot petDoc in petsSnapshot.docs) {
            Map<String, dynamic> petData = {
              'Name': petDoc['Name'],
              'Breed': petDoc['Breed'],
              'Age': petDoc['Age'],
              'Gender': petDoc['Gender'],
              'PetType': petDoc['PetType'], // Include PetType
              'ownerId': userDoc.id,
            };

            // Add PetType filter condition
            if ((selectedPetType == null ||
                    selectedPetType == petDoc['PetType']) &&
                (selectedBreed == null || selectedBreed == petDoc['Breed']) &&
                (selectedGender == null ||
                    selectedGender == petDoc['Gender'])) {
              loadedPets.add(petData);
            }
          }
        }
      }

      setState(() {
        pets = loadedPets;
        isLoading = false;
      });

      print('Total pets fetched: ${pets.length}');
    } catch (e) {
      print('Error fetching pets: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _storeLikeRequest(String likedBy, String liked) async {
    try {
      await FirebaseFirestore.instance.collection('requests').add({
        'likedBy': likedBy,
        'liked': liked,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Request stored: likedBy=$likedBy, liked=$liked');
    } catch (e) {
      print('Error storing request: $e');
    }
  }

  void likePet() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null && pets.isNotEmpty) {
      String likedBy = currentUser.uid;
      String liked = pets[currentIndex]['ownerId'];
      _storeLikeRequest(likedBy, liked);

      print('Liked ${pets[currentIndex]['Name']}');
      setState(() {
        pets.removeAt(currentIndex);
        if (pets.isNotEmpty) {
          currentIndex = currentIndex % pets.length;
        } else {
          _showNoMorePetsDialog(context);
        }
      });
    }
  }

  void passPet() {
    setState(() {
      pets.removeAt(currentIndex);
      if (pets.isNotEmpty) {
        currentIndex = currentIndex % pets.length;
      } else {
        _showNoMorePetsDialog(context);
      }
    });
  }

  void _showNoMorePetsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No more pets at the moment"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFilterDialog() async {
    String? selectedBreedLocal;
    String? selectedGenderLocal;
    String? selectedPetTypeLocal; // New property for selected pet type

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filter Pets"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add PetType selection
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Pet Type',
                ),
                items: ['Dog', 'Cat', 'Bird', 'Others'] // Customize as needed
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedPetTypeLocal = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Breed',
                ),
                onChanged: (value) {
                  selectedBreedLocal = value;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gender',
                ),
                items: ['male', 'female']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedGenderLocal = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedPetType = selectedPetTypeLocal;
                  selectedBreed = selectedBreedLocal;
                  selectedGender = selectedGenderLocal;
                  isLoading = true;
                });
                _fetchPets();
                Navigator.of(context).pop();
              },
              child: Text("Apply"),
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
        title: Text('EXPLORE'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : pets.isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Name: ${pets[currentIndex]['Name']}',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                'Breed: ${pets[currentIndex]['Breed']}',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                'Age: ${pets[currentIndex]['Age']}',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                'Gender: ${pets[currentIndex]['Gender']}',
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: passPet,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                            GestureDetector(
                              onTap: _showFilterDialog,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.search, color: Colors.white),
                              ),
                            ),
                            GestureDetector(
                              onTap: likePet,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child:
                                    Icon(Icons.favorite, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Text(
                    'No more pets to explore!',
                    style: TextStyle(fontSize: 20.0),
                  ),
      ),
    );
  }
}
