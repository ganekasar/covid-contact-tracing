import 'package:contacttracingprototype/components/rounded_button.dart';
import 'package:contacttracingprototype/components/userContact.dart';
import 'package:contacttracingprototype/constants.dart';
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


bool infectedStatus;
Firestore _firestore = Firestore.instance;

class ContactStream extends StatelessWidget {
  var loggedInUserEmail;
  ContactStream(loggedUserEmail){
    this.loggedInUserEmail=loggedUserEmail;
  }
  Future<String> getInfectedStatus(id) async {
    bool isInf;

    return await Firestore.instance
        .collection('users')
        .document(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data}');
        isInf = documentSnapshot.data['is infected'];
        return (documentSnapshot.data['is infected'] ? 'Infected' : 'Not Infected');
      } else {
        return 'No data available';
      }
    });

    return (isInf ? 'Infected' : 'Not Infected');
  }

  Future<String> getStringInf(String id) async {
    return await getInfectedStatus(id);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .document(loggedInUserEmail)
          .collection('met_with')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<ContactCard> messageBubbles = [];
        for (var message in messages) {
          final users = message.data['username'];
          final locationContact = message.data['contact location'];
          final timeContact = message.data['contact time'];
          final emailUser = message.data['user email'];

          Firestore.instance.collection('users')
              .where('username', isEqualTo: users)
              .snapshots()
              .listen((QuerySnapshot querySnapshot){
            querySnapshot.documents.forEach((document) {
              infectedStatus = document.data['is infected'];
              //print(infectedStatus);
            });
          }
          );
          String xyz;
          print(infectedStatus);
          if(infectedStatus==null)
            xyz="No data available";
          else
            xyz = infectedStatus ? 'Infected' : 'Not Infected';
          if(xyz == null)
            xyz = 'No data available';
          final messageBubble = ContactCard(
            imagePath: 'images/profile1.jpg',
            infection: xyz,
            contactUsername: users,
            email: emailUser,
            contactTime: timeContact,
            contactLocation: locationContact,
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

String isInfectedGlobal = 'Not available';

class InfectedStatus extends StatelessWidget {
  String userFind;
  InfectedStatus(email){
    userFind = email;
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('user')
            .document(userFind) //ID OF DOCUMENT
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('No data found');
            return new CircularProgressIndicator();
          }
          var document = snapshot.data;
          print('Infected Status');
          print(document['is infected']);
          if(document['is infected'])
            isInfectedGlobal = 'Infected';
          else
            isInfectedGlobal = 'Not Infected';
          return new Text(document['is infected'] ? 'Infected' : 'Not Infected');
        }
    );
  }
}
