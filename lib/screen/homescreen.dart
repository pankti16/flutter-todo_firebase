import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'addtodoscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  String currentUserUid = '';

  submitLogout() async {
    await auth.signOut();
  }

  submitAddTodo() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AddTodoScreen()));
  }

  getUid() async {
    final currentUser = auth.currentUser;
    final uid = currentUser!.uid;

    setState(() {
      currentUserUid = uid;
    });
  }

  void submitEdit(var taskData) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddTodoScreen(task: taskData)));
  }

  void submitDelete(var taskData) async {
    Navigator.of(context).pop();
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(currentUserUid)
        .collection('userTasks')
        .doc(taskData.id)
        .set({
      'id': taskData['id'],
      'title': taskData['title'],
      'description': taskData['description'],
      'status': 0,
      'time': DateTime.timestamp()
    });
    Fluttertoast.showToast(msg: 'Task deleted successfully!');
  }

  showDeleteAlertDialog(tasksData) {
    AlertDialog deleteAlert = AlertDialog(
      title:
      const Text('Are you sure to delete?'),
      content: Text(
          'Task with title ${tasksData["title"]} will be deleted.'),
      actions: [
        TextButton(
          child: const Text("Yes"),
          onPressed: () =>
              submitDelete(tasksData),
        ),
        TextButton(
          child: const Text("No"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return deleteAlert;
        });
  }

  @override
  void initState() {
    getUid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: Container()),
            const Text('Todo'),
            Text(
              'List',
              style: TextStyle(color: Colors.blue[800]),
            ),
            Expanded(child: Container()),
            IconButton(
              onPressed: submitLogout,
              icon: const Icon(
                Icons.exit_to_app,
                size: 24.0,
              ),
            ),
          ],
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .doc(currentUserUid)
              .collection('userTasks')
              .where('status', isEqualTo: 1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            } else {
              return snapshot.data!.docs.isEmpty
                  ? Center(
                      child: Text(
                        'Add new tasks',
                        style: GoogleFonts.roboto(fontSize: 20.0),
                      ),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final tasksData = snapshot.data!.docs[index];
                        return Slidable(
                          key: ValueKey(tasksData['id']),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (BuildContext context) =>
                                    submitEdit(tasksData),
                                backgroundColor: const Color(0xFF66BB6A),
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                // label: 'Edit',
                              ),
                              SlidableAction(
                                onPressed: (BuildContext context) => showDeleteAlertDialog(tasksData),
                                backgroundColor: const Color(0xFFEF5350),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                // label: 'Delete',
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              tasksData['title'],
                            ),
                            subtitle: Text(tasksData['description']),
                          ),
                        );
                      });
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: submitAddTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
