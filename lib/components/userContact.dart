import 'package:flutter/material.dart';
import 'bottom_sheet_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../components/listOfContacts.dart';

Firestore _firestore = Firestore.instance;

class UserCard extends StatelessWidget {
  UserCard(
      {this.imagePath,
        this.infection,
        this.contactUsername,this.contactEmail});

  final String imagePath;
  final String infection;
  final String contactUsername;
  final String contactEmail;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(imagePath),
        ),
        trailing: Icon(Icons.more_horiz),
        title: Text(
          contactUsername!=null ?contactUsername:"NULL",
          style: TextStyle(
            color: Colors.deepPurple[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(infection),
        onTap: () => showModalBottomSheet(
            context: context,
            builder: (builder) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 10.0),
                child: Column(
                  children: <Widget>[
                    BottomSheetText(
                        question: 'Username', result: contactUsername),
                    SizedBox(height: 5.0),
                    ElevatedButton(onPressed: (){
                      _firestore
                          .collection('users')
                          .document(contactEmail)
                          .updateData({
                        'is infected': true,
                      });
                    },
                        child: Text("Mark as Infected")),
                    SizedBox(height: 5.0),
                    ElevatedButton(onPressed: () {
                      _firestore
                          .collection('users')
                          .document(contactEmail)
                          .updateData({
                        'is infected': false,
                      });
                    },
                        child: Text("Mark as Not Infected")),
                    SizedBox(height: 5.0),
                    ContactStream(contactEmail),
                    SizedBox(height: 5.0),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
