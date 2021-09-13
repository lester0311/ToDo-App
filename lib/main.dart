//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        accentColor: Colors.brown),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List todos = [];
  String input = "";

  createTodos() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("ToDo App").doc(input);

    Map<String, String> todos = {"todoTitle": input};
    documentReference
        .set(todos)
        .whenComplete(() => print("$input successfully created"));
  }

  updateTodos(upTodo) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("ToDo App").doc(upTodo);

    Map<String, String> todos = {"todoTitle": input};

    documentReference
        .update(todos)
        .whenComplete(() => print("$upTodo Updated"));
  }

  deleteTodos(delTodo) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("ToDo App").doc(delTodo);

    documentReference.delete().whenComplete(() => print("$delTodo Deleted"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo App"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  title: Text("Add Todo"),
                  content: TextField(
                    onChanged: (String value) {
                      input = value;
                    },
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          createTodos();
                          Navigator.of(context).pop();
                        },
                        child: Text("Add"))
                  ],
                );
              });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("ToDo App").snapshots(),
          builder: (context, AsyncSnapshot snapshots) {
            if (snapshots.data == null) return CircularProgressIndicator();
            return ListView.builder(
                itemCount: snapshots.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      snapshots.data.docs[index];
                  return Dismissible(
                      onDismissed: (direction) {
                        deleteTodos(documentSnapshot["todoTitle"]);
                      },
                      key: Key(documentSnapshot["todoTitle"]),
                      child: Card(
                        elevation: 5,
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(documentSnapshot["todoTitle"]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            title: Text("Update Todo"),
                                            content: TextField(
                                              onChanged: (String value) {
                                                input = value;
                                              },
                                            ),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                  onPressed: () {
                                                    updateTodos(
                                                        documentSnapshot[
                                                            "todoTitle"]);
                                                  },
                                                  child: Text("Edit"))
                                            ],
                                          );
                                        });
                                  },
                                  icon:
                                      Icon(Icons.edit, color: Colors.blueGrey)),
                              IconButton(
                                  onPressed: () {
                                    deleteTodos(documentSnapshot["todoTitle"]);
                                  },
                                  icon: Icon(Icons.delete,
                                      color: Colors.blueGrey)),
                            ],
                          ),
                        ),
                      ));
                });
          }),
    );
  }
}
