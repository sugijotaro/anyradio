import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'radio_player_screen.dart';

class RadioListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radio List'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('radios').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var radios = snapshot.data!.docs;

          return ListView.builder(
            itemCount: radios.length,
            itemBuilder: (context, index) {
              var radio = radios[index];
              return ListTile(
                title: Text(radio['title']),
                subtitle: Text(radio['description']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RadioPlayerScreen(
                        audioUrl: radio['audioUrl'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}