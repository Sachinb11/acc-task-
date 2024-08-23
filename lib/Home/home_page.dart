import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login/login.dart';
import 'post_card.dart';
import 'post_creation_page.dart';
import 'HomeController.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final HomeController homeController = Get.put(HomeController());
  int _selectedIndex = 0;

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black87, // Black background for the dialog
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
            side: BorderSide(color: Colors.white54, width: 2.0), // Light white border
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirm Logout',
                  style: TextStyle(color: Colors.white, fontSize: 18.0), // White text for title
                ),
                SizedBox(height: 16.0),
                Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(color: Colors.white), // White text for content
                ),
                Divider(color: Colors.pink,),

                SizedBox(height: 16.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.pink), // Pink button background
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Rounded corners for button
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('Cancel', style: TextStyle(color: Colors.white)), // White text for button
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.pink), // Pink button background
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // Rounded corners for button
                          ),
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut(); // Sign out user
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginPage()), // Navigate to login page
                        );
                      },
                      child: Text('Logout', style: TextStyle(color: Colors.white)), // White text for button
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildBody() {
      switch (_selectedIndex) {
        case 0:
          return Obx(() {

            if (homeController.posts.isEmpty) {
              return Center(child: Text('No posts yet', style: TextStyle(color: Colors.white)));
            }
            return ListView.builder(
              itemCount: homeController.posts.length,
              itemBuilder: (context, index) {
                final post = homeController.posts[index];
                return PostCard(post: post);
              },
            );
          });
        case 1:
          return PostCreationPage();
        case 2:
        // Implement search functionality here
          return Center(child: Text('Search', style: TextStyle(color: Colors.white)));
        case 3:
          return ProfilePage();
        default:
          return Container();
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Social Media App', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.pink),
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

}
