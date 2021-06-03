import 'package:contacttracingprototype/components/rounded_button.dart';
import 'package:contacttracingprototype/components/userContact.dart';
import 'package:contacttracingprototype/constants.dart';
import 'nearby_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:nearby_connections/nearby_connections.dart';
import '../components/contact_card.dart';
import '../constants.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'welcome_screen.dart';

class AdminScreen extends StatefulWidget {
  static const String id = 'admin_screen';

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Firestore _firestore = Firestore.instance;
  FirebaseUser loggedInUser;
  String testText = '';
  final _auth = FirebaseAuth.instance;
  List<dynamic> users = [];
  List<dynamic> contactTimes = [];
  List<dynamic> contactLocations = [];
  List<String> infectedStatus = [];

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    await getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
      Navigator.pushNamed(context, WelcomeScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Covid Tracing Admin',
          style: TextStyle(
            color: Colors.deepPurple[800],
            fontWeight: FontWeight.bold,
            fontSize: 28.0,
          ),
        ),
        backgroundColor: Colors.orange,
        actions: [
          TextButton(
            onPressed: () {
              _auth.signOut();
              Navigator.pushNamed(context, WelcomeScreen.id);
            },
            child: const Text('Log Out'),
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
              primary: Colors.white,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple[800],
              ),
              child: loggedInUser != null
                  ? Text(loggedInUser.email)
                  : Text("Loading"),
            ),
            ListTile(
              title: Text('I am Infected'),
              onTap: () {
                // Update the state of the app
                setState(() {
                  _firestore
                      .collection('users')
                      .document(loggedInUser.email)
                      .setData({
                    'is infected': true,
                  });
                  print("infected");
                });
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Refresh'),
              onTap: () {
                // Update the state of the app
                setState(() {});
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('I am Not Infected'),
              onTap: () {
                // Update the state of the app
                setState(() {
                  _firestore
                      .collection('users')
                      .document(loggedInUser.email)
                      .setData({
                    'is infected': false,
                  });
                  print(" Not infected");
                });
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Restart'),
              onTap: () {
                // Update the state of the app
                Phoenix.rebirth(context);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 25.0,
                right: 25.0,
                bottom: 10.0,
                top: 30.0,
              ),
              child: Container(
                height: 50.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[500],
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 4.0,
                      spreadRadius: 0.0,
                      offset: Offset(2.0, 2.0),
                    )
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Image(
                        image: AssetImage('images/corona.png'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          UserStream(),
        ],
      ),
    );
  }
}


class UserStream extends StatelessWidget {
  Firestore _firestore = Firestore.instance;
  FirebaseUser loggedInUser;
  String testText = '';
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<UserCard> messageBubbles = [];
        for (var message in messages) {
          final users = message.data['username'];
          final infectedStatus = message.data['is infected'] ? "Infected": "Not Infected" ;

          final messageBubble = UserCard(
            imagePath: 'images/profile1.jpg',
            infection: infectedStatus,
            contactUsername: users,
          );

          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}