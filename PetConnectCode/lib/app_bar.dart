import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final FirebaseAuth auth;

  MainAppBar({required this.auth});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('PET CONNECT'),
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {
          // Handle menu button press
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
      ],
    );
  }
}
