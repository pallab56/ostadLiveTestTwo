import 'package:flutter/material.dart';
import 'package:ostadlivetesttwo/models/task.dart';
import 'package:ostadlivetesttwo/service/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;

  String? _task;

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SimpleTodo')),
      body: _taskList(),

      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _task = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Add.....',
                    border: OutlineInputBorder(),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    if (_task == null || _task == "") return;
                    _databaseServices.addTask(_task!);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('$_task ADDED')));
                    setState(() {
                      _task = null;
                    });
                    Navigator.pop(context);
                  },
                  color: Colors.red,
                  child: Text('Done'),
                ),
              ],
            ),
          ),
        );
      },
      child: Icon(Icons.add),
    );
  }

  Widget _taskList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(),
              hintText: "Search by title",
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.all(10),
              fixedSize: Size.fromWidth(200),
            ),
            onPressed: () {},
            child: Text("search", style: TextStyle(color: Colors.white)),
          ),
          Expanded(
            child: FutureBuilder(
              future: _databaseServices.getTasks(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      Task task = snapshot.data![index];
                      return ListTile(
                        leading: Checkbox(
                          value: task.status == 1,
                          onChanged: (value) {
                            _databaseServices.updateTaskStatus(
                              task.id,
                              value == true ? 1 : 0,
                            );
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${task.content} status Updated Successfully"),
                              ),
                            );
                          },
                        ),
                        title: Text(task.content),
                        trailing: IconButton(
                          onPressed: () {
                            _databaseServices.deleteTask(task.id);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${task.content} Task deleted Successfully"),
                              ),
                            );
                          },
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      );
                    },
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
