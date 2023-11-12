import 'package:flutter/material.dart';

class AddUserScreen extends StatefulWidget {
  static const String routeName = '/add';

  const AddUserScreen({super.key});

  @override
  AddUserScreenState createState() => AddUserScreenState();
}

class AddUserScreenState extends State<AddUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
      ),
      body: Center(
        child: Text('Add User Screen'),
      ),
    );
  }
}
