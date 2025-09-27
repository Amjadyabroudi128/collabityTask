import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _taskController = TextEditingController();

  final List<Map<String, dynamic>> _tasks = [
    {"id": 1, "title": "Buy groceries", "done": false},
    {"id": 2, "title": "Walk the dog", "done": false},
    {"id": 3, "title": "Finish Flutter project", "done": false},
  ];
  int _nextId = 4;

  void _addTask() {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tasks.add({"id": _nextId++, "title": text, "done": false});
      _taskController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Tasks"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        hintText: "Enter a new task",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onFieldSubmitted: (_) => _addTask(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _addTask();
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Dismissible(
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    key: ValueKey(task["id"]),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      final deletedTask =
                          task["title"]; // store before removing
                      setState(() {
                        _tasks.removeAt(index);
                      });
                      // Show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$deletedTask has been deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                _tasks.insert(index, {
                                  "id": DateTime.now().millisecondsSinceEpoch,
                                  "title": deletedTask,
                                  "done": false,
                                });
                              });
                            },
                          ),
                        ),
                      );
                    },
                    confirmDismiss: (direction) async => true,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          activeColor: Colors.green,
                          value: task["done"],
                          onChanged: (value) {
                            setState(() {
                              task["done"] = value ?? false;
                            });
                          },
                        ),
                        title: Text(
                          task["title"],
                          style: TextStyle(
                            fontSize: 16,
                            decoration: task["done"]
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                          ),
                          onSelected: (value) async {
                            if (value == "edit") {
                              _editTask(index);
                            }
                            if (value == "delete") {
                              final deletedTask =
                                  task["title"]; // store before removing
                              await deleteTask(context, index, deletedTask);
                            }
                          },
                          icon: const Icon(Icons.more_horiz),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete),
                                  title: Text('Delete'),
                                  iconColor: Colors.red,
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> deleteTask(BuildContext context, int index, deletedTask) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("You are about to delete ${_tasks[index]["title"]}"),
        content: Text("Are you sure?", style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tasks.removeAt(index);
              });
              Navigator.of(ctx).pop(null);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$deletedTask has been deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        _tasks.insert(index, {
                          "id": DateTime.now().millisecondsSinceEpoch,
                          "title": deletedTask,
                          "done": false,
                        });
                      });
                    },
                  ),
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _editTask(int index) async {
    final current = _tasks[index]["title"] as String;
    final controller = TextEditingController(text: current);

     await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Task"),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Update task title",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.black, width: 2.0),
            ),
          ),
          onFieldSubmitted: (value) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) Navigator.of(ctx).pop(trimmed);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel",style: TextStyle(color: Colors.black, fontSize: 16),),
          ),
          TextButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please add something')),
                  );
                }
              } else if (trimmed == current.trim()) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nothing has changed')),
                  );
                }
              } else {
                setState(() {
                  _tasks[index]["title"] = trimmed;
                });
                Navigator.of(ctx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task has been updated')),
                  );
                }
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.green, fontSize: 16),),
          ),
        ],
      ),
    );
  }
}
