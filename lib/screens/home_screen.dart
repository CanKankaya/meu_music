import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meu_music/services/auth.dart';

class HomeScreen extends StatelessWidget {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Users'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: usersCollection.snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              log(snapshot.error.toString());
              log(snapshot.data.toString());
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView(
              children: snapshot.data?.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['name'] ?? "No name"),
                      subtitle: Text(data['studentId'] ?? "No student ID"),
                    );
                  }).toList() ??
                  [],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add');
          },
          child: const Icon(Icons.add),
        ));
  }
}
