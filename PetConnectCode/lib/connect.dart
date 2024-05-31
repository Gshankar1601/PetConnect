import 'package:csvpro/chat.dart';
import 'package:flutter/material.dart';
import 'explore.dart';
import 'con_req.dart';
import 'show_match.dart';
import 'match_user.dart';

class Connect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Connect',
          style: TextStyle(
            color: Colors.white, // Change this to your desired color
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 64, 61, 68),
        iconTheme: IconThemeData(
            color: Colors.white), // Change the color of the icons in the AppBar
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.png', // Replace with your background image path
            fit: BoxFit.cover,
          ),
          Container(
            color:
                Colors.black.withOpacity(0.5), // Dark overlay for readability
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ExploreScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor:
                          Colors.yellow, // Set the text color to black
                      padding: EdgeInsets.symmetric(
                          vertical: 26.0), // Reduced height
                      textStyle:
                          TextStyle(fontSize: 30.0), // Increased font size
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12.0), // Rounded square shape
                      ),
                      minimumSize: Size(200, 50), // Increased width
                    ),
                    child: Text('Explore'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MatchedUsersScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.yellow,
                      padding: EdgeInsets.symmetric(
                          vertical: 26.0), // Reduced height
                      textStyle:
                          TextStyle(fontSize: 30.0), // Increased font size
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12.0), // Rounded square shape
                      ),
                      minimumSize: Size(200, 50), // Increased width
                    ),
                    child: Text('Friends'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConnectionRequestsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.yellow,
                      padding: EdgeInsets.symmetric(
                          vertical: 26.0), // Reduced height
                      textStyle:
                          TextStyle(fontSize: 30.0), // Increased font size
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12.0), // Rounded square shape
                      ),
                      minimumSize: Size(200, 50), // Increased width
                    ),
                    child: Text('Requests'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MatchScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.yellow,
                      padding: EdgeInsets.symmetric(
                          vertical: 26.0), // Reduced height
                      textStyle:
                          TextStyle(fontSize: 30.0), // Increased font size
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12.0), // Rounded square shape
                      ),
                      minimumSize: Size(200, 50), // Increased width
                    ),
                    child: Text('Messages'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
