import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of data containers
  List<Map<String, String>> containers = [];
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('students').snapshots();

  // Function to add or edit data
  void _showBottomSheet(BuildContext context,
      {Map<String, String>? container, int? index}) {
    final nameController =
        TextEditingController(text: container?['name'] ?? '');
    final phController = TextEditingController(text: container?['ph'] ?? '');
    final locationController =
        TextEditingController(text: container?['location'] ?? '');

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      phController.text.isNotEmpty &&
                      locationController.text.isNotEmpty) {
                    if (index == null) {
                      // Adding new data
                      setState(() {
                        containers.add({
                          'name': nameController.text,
                          'ph': phController.text,
                          'location': locationController.text,
                        });
                      });
                    } else {
                      // Editing existing data
                      setState(() {
                        containers[index] = {
                          'name': nameController.text,
                          'ph': phController.text,
                          'location': locationController.text,
                        };
                      });
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(index == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to delete container
  void _deleteContainer(int index) {
    setState(() {
      containers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Container List'),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasData) {
            ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final studentList = snapshot.data!.docs;
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    title: Text(studentList[index]["name"]),
                    subtitle: Text(
                        'Phone: ${studentList[index]["ph"]} - Location: ${studentList[index]["location"]}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteContainer(index),
                    ),
                    // onTap: () => _showBottomSheet(context,
                    //     container: container, index: index),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
