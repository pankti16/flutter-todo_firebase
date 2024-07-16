import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';


class AddTodoScreen extends StatefulWidget {
  final task;
  const AddTodoScreen ({super.key, this.task});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  bool isEnable = true;
  bool isEdit = false;

  submitAddTodo() async {
    if (!isEnable) return;
    var title = titleController!.text;
    var description = descController!.text;

    final isValid = title!.isNotEmpty && description!.isNotEmpty;

    if (isValid) {
      setState(() {
        isEnable = false;
      });

      final FirebaseAuth auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      final currentUserUid = currentUser!.uid;

      var lastIdReq = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(currentUserUid)
          .collection('userTasks')
          .orderBy('id', descending: true)
          .limit(1)
          .get();
      var lastTask = lastIdReq.docs!.isEmpty ? {} : lastIdReq.docs.first.data() as Map;
      int lastId = (int.tryParse(lastTask['id'].toString()) ?? 0) + 1;

      await FirebaseFirestore.instance.collection('tasks').doc(currentUserUid).collection('userTasks').add({
        'id': lastId,
        'title': title,
        'description': description,
        'status': 1,
        'time': DateTime.timestamp(),
      });

      Fluttertoast.showToast(
          msg: "Task added successfully!",
      ).then((v) => {
        Navigator.pop(context)
      });
    }
  }

  submitEditTodo() async {
    if (!isEnable) return;
    var title = titleController!.text;
    var description = descController!.text;

    final isValid = title!.isNotEmpty && description!.isNotEmpty;

    if (isValid) {
      setState(() {
        isEnable = false;
      });

      final FirebaseAuth auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      final currentUserUid = currentUser!.uid;

      await FirebaseFirestore.instance.collection('tasks').doc(currentUserUid).collection('userTasks').doc(widget.task.id).set({
        'id': widget.task['id'],
        'title': title,
        'description': description,
        'status': 1,
        'time': DateTime.timestamp(),
      });

      Fluttertoast.showToast(
        msg: "Task updated successfully!",
      ).then((v) => {
        Navigator.pop(context)
      });
    }
  }

  @override
  void initState() {
    super.initState();
    try {
      // final taskData = ModalRoute.of(context)!.settings.arguments;
      final taskData = widget.task;
      print(taskData);
      if (taskData != null) {
        setState(() {
          isEdit = true;
          // task = taskData;
        });
        titleController.value = TextEditingValue(
          text: taskData['title'],
        );
        descController.value = TextEditingValue(
          text: taskData['description'],
        );
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: Container()),
            Text(isEdit ? 'Edit' : 'Add'),
            Text(
              'Todo',
              style: TextStyle(color: Colors.blue[800]),
            ),
            Expanded(child: Container()),
            Expanded(child: Container()),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                key: const ValueKey('title'),
                controller: titleController,
                enabled: isEnable,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter title',
                  labelStyle: GoogleFonts.roboto(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                height: 200.0,
                child: TextField(
                  key: const ValueKey('description'),
                  controller: descController,
                  enabled: isEnable,
                  maxLines: null,
                  minLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter description',
                    labelStyle: GoogleFonts.roboto(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                height: 60.0,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isEdit ? submitEditTodo : submitAddTodo,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                        isEnable ? Colors.blue : Colors.grey),
                  ),
                  child: isEnable
                      ? Text(
                          isEdit ? 'Edit Todo' : 'Add Todo',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        )
                      : const Center(
                          child: CupertinoActivityIndicator(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
