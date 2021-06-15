import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacttracingprototype/components/notification_stream.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:nearby_connections/nearby_connections.dart';
import '../constants.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'welcome_screen.dart';
import '../components/listOfContacts.dart';

Location location = Location();
Firestore _firestore = Firestore.instance;
FirebaseUser loggedInUser;
String testText = '';
final Strategy strategy = Strategy.P2P_STAR;
final _auth = FirebaseAuth.instance;

class NearbyInterface extends StatefulWidget {
  static const String id = 'nearby_interface';
  @override
  _NearbyInterfaceState createState() => _NearbyInterfaceState();
}

class _NearbyInterfaceState extends State<NearbyInterface> {
  void addContactsToList() async {
    await getCurrentUser();
  }

  void deleteOldContacts(int threshold) async {
    await getCurrentUser();
    DateTime timeNow = DateTime.now(); //get today's time

    _firestore
        .collection('users')
        .document(loggedInUser.email)
        .collection('met_with')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.documents) {
        if (doc.data.containsKey('contact time')) {
          DateTime contactTime =
              (doc.data['contact time'] as Timestamp).toDate();
          if (timeNow.difference(contactTime).inDays > threshold) {
            doc.reference.delete();
          }
        }
      }
    });

    setState(() {});
  }

  void discovery() async {
    await getCurrentUser();
    try {
      bool a = await Nearby().startDiscovery(loggedInUser.email, strategy,
          onEndpointFound: (id, name, serviceId) async {
        print('I saw id:$id with name:$name');
        var docRef =
            _firestore.collection('users').document(loggedInUser.email);
        var username = await getUsernameOfEmail(email: name);
        var loc = (await location.getLocation()).toString();
        docRef.collection('met_with').document(name).setData({
          'username': (username != null) ? username : 'anonymous',
          'contact time': DateTime.now(),
          'contact location': loc,
          'user email': name,
        });
      }, onEndpointLost: (id) {
        print(id);
      });
      print('DISCOVERING: ${a.toString()}');
    } catch (e) {
      print(e);
      print('Unable to DISCOVER');
    }
  }

  void getPermissions() {
    Nearby().askLocationAndExternalStoragePermission();
  }

  Future<String> getUsernameOfEmail({String email}) async {
    String res = '';
    await _firestore.collection('users').document(email).get().then((doc) {
      if (doc.exists) {
        res = doc.data['username'];
      } else {
        print("No such document!");
      }
    });
    return res;
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
  void initState() {
    super.initState();
    deleteOldContacts(14);
    addContactsToList();
    getPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Covid Tracing',
          style: TextStyle(
            color: Colors.deepPurple[800],
            fontWeight: FontWeight.bold,
            fontSize: 28.0,
          ),
        ),
        backgroundColor: Colors.orange,
        actions: [
          TextButton(
              onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (builder) {
                    return NotificationStream(loggedInUser.email);
                  }
              ),
              child: const Icon(
                Icons.notification_important,
                size: 30.0,
                color: Colors.deepPurple,
              ),
          ),
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
                height: 100.0,
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
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Your Contact Traces',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 21.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 30.0),
            // ignore: deprecated_member_use
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              elevation: 5.0,
              color: Colors.deepPurple[400],
              onPressed: () async {
                try {
                  bool a = await Nearby().startAdvertising(
                    loggedInUser.email,
                    strategy,
                    onConnectionInitiated: null,
                    onConnectionResult: (id, status) {
                      print(status);
                    },
                    onDisconnected: (id) {
                      print('Disconnected $id');
                    },
                  );

                  print('ADVERTISING ${a.toString()}');
                } catch (e) {
                  print(e);
                }

                discovery();
              },
              child: Text(
                'Start Tracing',
                style: kButtonTextStyle,
              ),
            ),
          ),
          ContactStream(loggedInUser.email),
        ],
      ),
    );
  }
}

