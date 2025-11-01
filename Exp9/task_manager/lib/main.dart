import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'db/database_helper.dart';
import 'model/task_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // ✅ Enable web SQLite (IndexedDB)
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // ✅ Enable native SQLite for desktop/mobile
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: TaskListPage(),
    );
  }
}

class TaskListPage extends StatefulWidget {
  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final dbHelper = DatabaseHelper.instance;
  List<Task> tasks = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future<void> _refreshTasks() async {
    final data = await dbHelper.getTasks();
    setState(() => tasks = data);
  }

  Future<void> _addTask(String title) async {
    if (title.isEmpty) return;
    await dbHelper.insertTask(Task(title: title));
    _controller.clear();
    _refreshTasks();
  }

  Future<void> _toggleTask(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      isDone: task.isDone == 0 ? 1 : 0,
    );
    await dbHelper.updateTask(updatedTask);
    _refreshTasks();
  }

  Future<void> _deleteTask(int id) async {
    await dbHelper.deleteTask(id);
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Task Manager")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter new task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addTask(_controller.text),
                  child: Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone == 1
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 12,
                      children: [
                        IconButton(
                          icon: Icon(
                            task.isDone == 1
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: task.isDone == 1
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onPressed: () => _toggleTask(task),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
