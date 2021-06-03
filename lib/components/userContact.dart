import 'package:flutter/material.dart';
import 'bottom_sheet_text.dart';

class UserCard extends StatelessWidget {
  UserCard(
      {this.imagePath,
        this.infection,
        this.contactUsername,});

  final String imagePath;
  final String infection;
  final String contactUsername;

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
      ),
    );
  }
}
