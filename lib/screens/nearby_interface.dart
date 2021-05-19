import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:nearby_connections/nearby_connections.dart';
import '../components/contact_card.dart';
import '../constants.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class NearbyInterface extends StatefulWidget {
  static const String id = 'nearby_interface';

  @override
  _NearbyInterfaceState createState() => _NearbyInterfaceState();
}

class _NearbyInterfaceState extends State<NearbyInterface> {
  Location location = Location();
  Firestore _firestore = Firestore.instance;
  final Strategy strategy = Strategy.P2P_STAR;
  FirebaseUser loggedInUser;
  String testText = '';
  final _auth = FirebaseAuth.instance;
  List<dynamic> contactTraces = [];
  List<dynamic> contactTimes = [];
  List<dynamic> contactLocations = [];
  List<String> contactInfection = [];

  void addContactsToList() async {
    await getCurrentUser();

    _firestore
        .collection('users')
        .document(loggedInUser.email)
        .collection('met_with')
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.documents) {
            String currUsername = doc.data['username'];
            String currEmail = doc.data['user email'];
            DateTime currTime = doc.data.containsKey('contact time') ? (doc.data['contact time'] as Timestamp).toDate() : null;
            String currLocation = doc.data.containsKey('contact location') ? doc.data['contact location'] : null;
            bool ifInfected = false;
            print(currUsername);
            Firestore.instance.collection('users').document(currEmail).get().then((DocumentSnapshot ds) {
              print(currEmail);
              print(ds['is infected']);
              ifInfected = ds['is infected'];
              if (!contactTraces.contains(currUsername)) {
                contactTraces.add(currUsername);
                contactTimes.add(currTime);
                contactLocations.add(currLocation);
                if(ifInfected == true) {
                  contactInfection.add("Infected");
                } else {
                  contactInfection.add("Not Infected");
                }
              }
            });
          }
          setState(() {});
          print(loggedInUser.email);
        });
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
              DateTime contactTime = (doc.data['contact time'] as Timestamp)
              .toDate();
              if (timeNow.difference(contactTime).inDays > threshold) {
                doc.reference.delete();
              }
            }
          }
        });

    setState(() {});
  }

  void discovery() async {
    try {
      bool a = await Nearby().startDiscovery(loggedInUser.email, strategy,
          onEndpointFound: (id, name, serviceId) async {
            print('I saw id:$id with name:$name');
            var docRef =
              _firestore.collection('users').document(loggedInUser.email);
            print(await getUsernameOfEmail(email: name));
            docRef.collection('met_with').document(name).setData({
              'username' : await getUsernameOfEmail(email: name),
              'contact time': DateTime.now(),
              'contact location': (await location.getLocation()).toString(),
              'user email':name,
            });
          }, onEndpointLost: (id) {
          print(id);
      });
      print('DISCOVERING: ${a.toString()}');
    } catch (e) {
      print(e);
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
      }
    } catch (e) {
      print(e);
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
      ),
      drawer: Drawer(
      child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.deepPurple[800],
          ),
          child: Text(loggedInUser.email),
        ),
        ListTile(
          title: Text('I am Infected'),
          onTap: () {
            // Update the state of the app
            setState(() {
              _firestore.collection('users').document(loggedInUser.email).setData({
                'is infected':true,
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
              _firestore.collection('users').document(loggedInUser.email).setData({
                'is infected':false,
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
                      offset:
                          Offset(2.0, 2.0),
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
            child: ElevatedButton(
              onPressed: () async {
                try {
                 // Nearby().stopAdvertising();
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
                }
                catch (e) {
                  print(e);
                }
                //Nearby().stopDiscovery();
                discovery();
              },
              child: Text(
                'Start Tracing',
                style: kButtonTextStyle,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: ListView.builder(
                itemCount:contactTraces.length,
                itemBuilder: (context, index) {
                  return ContactCard(
                    imagePath: 'images/profile1.jpg',
                    email: contactTraces[index],
                    infection: contactInfection[index],
                    contactUsername: contactTraces[index],
                    contactTime: contactTimes[index],
                    contactLocation: contactLocations[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}


