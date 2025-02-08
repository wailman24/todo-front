import 'package:flutter/material.dart';
import 'package:flutter_application_1/todo_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final token;
  const Home({@required this.token, super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void initState() {
    super.initState();
    getTasks(); // Fetch tasks when the screen loads
  }

  late String userId;
  TextEditingController taskController = TextEditingController();

  List<Map<String, dynamic>> tasks = [];

  Future<void> getTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Retrieve the stored token

    if (token == null) {
      print("No token found, please log in again.");
      return;
    }

    var response = await http.get(
      // use your own pc's ip adress or use 10.0.2.2 for emulators
      Uri.parse("http://192.168.1.69:3000/api/tasks"),
      headers: {"Content-Type": "application/json", "x-auth-token": token},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);

      setState(() {
        tasks = jsonResponse
            .map((task) => Map<String, dynamic>.from(task))
            .toList();
      });

      print("User Tasks: $tasks");
    } else {
      print("Error fetching tasks: ${response.body}");
    }
  }

  Future<void> addTask() async {
    if (taskController.text.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("No token found, please log in again.");
      return;
    }

    var response = await http.post(
      // use your own pc's ip adress or use 10.0.2.2 for emulators
      Uri.parse("http://192.168.1.69:3000/api/tasks"),
      headers: {"Content-Type": "application/json", "x-auth-token": token},
      body: jsonEncode({"title": taskController.text}),
    );

    if (response.statusCode == 200) {
      var newTask = jsonDecode(response.body);
      tasks.add(newTask);

      taskController.clear();
      getTasks();
      setState(() {});
    } else {
      print("Failed to add task");
    }
  }

  Future<void> update(
      BuildContext context, String taskId, bool newStatus) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print("No token found, please log in again.");
        return;
      }

      var response = await http.put(
          // use your own pc's ip adress or use 10.0.2.2 for emulators
          Uri.parse("http://192.168.1.69:3000/api/tasks/$taskId"),
          headers: {"Content-Type": "application/json", "x-auth-token": token},
          body: jsonEncode({"completed": newStatus}));
      if (response.statusCode == 200) {
        setState(() {
          int index = tasks.indexWhere((task) => task['_id'] == taskId);
          if (index != -1) {
            tasks[index]['completed'] = newStatus;
          }
        });
      } else {
        print("Error updating task: ${response.body}");
      }
    } catch (error) {
      print("Exception: $error");
    }
  }

  Future<void> deleteItem(BuildContext context, String taskId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print("No token found, please log in again.");
        return;
      }

      var response = await http.delete(
          // use your own pc's ip adress or use 10.0.2.2 for emulators
          Uri.parse("http://192.168.1.69:3000/api/tasks/$taskId"),
          headers: {"Content-Type": "application/json", "x-auth-token": token});

      if (response.statusCode == 200) {
        setState(() {
          tasks.removeWhere((task) => task['_id'] == taskId);
        });
      } else {
        print("Error deleting task: ${response.body}");
      }
    } catch (error) {
      print("Exception: $error");
    }
  }

  void checkboxchanged(int index) {
    setState(() {
      tasks[index]['completed'] = !tasks[index]['completed'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade300,
      appBar: AppBar(
        title: Text("my TODO App"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, index) {
                var sortedTasks = List.from(tasks);
                sortedTasks.sort((a, b) => a['completed'] ? 1 : -1);

                return Todolist(
                  id: sortedTasks[index]['_id'],
                  task: sortedTasks[index]['title'],
                  taskcomp: sortedTasks[index]['completed'],
                  update: update,
                  deletetask: deleteItem,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      hintText: 'Add task',
                      filled: true,
                      fillColor: Colors.deepPurple.shade200,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.deepPurple,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10), // Add some spacing
                FloatingActionButton(
                  onPressed: () {
                    addTask();
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
