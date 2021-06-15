import '../components/userContact.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          'Covid Admin',
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
                  ? Text(loggedInUser.email,style: TextStyle(fontSize: 35.0,fontStyle: FontStyle.italic,fontWeight: FontWeight.w900),)
                  : Text("Loading"),
            ),
            ListTile(
              leading: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    _firestore
                        .collection('users')
                        .document(loggedInUser.email)
                        .updateData({
                      'is infected': true,
                    });
                    print("infected");
                  });
                  // Then close the drawer
                  Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  alignment: Alignment.center,
                  child: const CircleAvatar(),
                ),
              ),
              title: Text('Infected',style: TextStyle(fontSize: 25.0),),
              onTap: () {
                // Update the state of the app
                setState(() {
                  _firestore
                      .collection('users')
                      .document(loggedInUser.email)
                      .updateData({
                    'is infected': true,
                  });
                  print("infected");
                });
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {});
                  // Then close the drawer
                  Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  alignment: Alignment.center,
                  child: const CircleAvatar(),
                ),
              ),
              title: Text('Refresh',style: TextStyle(fontSize: 25.0,color: Colors.green),),
              onTap: () {
                // Update the state of the app
                setState(() {});
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    _firestore
                        .collection('users')
                        .document(loggedInUser.email)
                        .updateData({
                      'is infected': false,
                    });
                    print(" Not infected");
                  });
                  // Then close the drawer
                  Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  alignment: Alignment.center,
                  child: const CircleAvatar(),
                ),
              ),
              title: Text('Not Infected',style: TextStyle(fontSize: 25.0),),
              onTap: () {
                // Update the state of the app
                setState(() {
                  _firestore
                      .collection('users')
                      .document(loggedInUser.email)
                      .updateData({
                    'is infected': false,
                  });
                  print(" Not infected");
                });
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  // Update the state of the app
                  Phoenix.rebirth(context);
                  // Then close the drawer
                  Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  alignment: Alignment.center,
                  child: const CircleAvatar(),
                ),
              ),
              title: Text('Restart',style: TextStyle(fontSize: 25.0,color: Colors.red),),
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
  final Firestore _firestore = Firestore.instance;

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
          final userEmail=message.documentID;
          final users = message.data['username'];
          bool data=message.data['is infected'];
          String infectedStatus ;
          if(data==null){
            infectedStatus="Loading";
          }else{
            infectedStatus =  data ? "Infected": "Not Infected" ;
        }

          final messageBubble = UserCard(
            imagePath: 'images/profile1.jpg',
            infection: infectedStatus,
            contactUsername: users,
            contactEmail:userEmail,
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