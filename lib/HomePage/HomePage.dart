import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key,});

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
      appBar: AppBar(
        title: Text("My Tasks"),
        centerTitle: true,
      ),
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
                          borderRadius: BorderRadius.circular(15)
                        ),
                      ),
                      onFieldSubmitted: (_) => _addTask(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: (){
                    _addTask();
                  },
                )
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index){
                  return Dismissible(
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.delete,color: Colors.white,),
                      ),
                    ),
                    key: ValueKey(_tasks[index]["id"]),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      final deletedTask = _tasks[index]["title"]; // store before removing
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
                                _tasks.insert(index, {"id": DateTime.now().millisecondsSinceEpoch, "title": deletedTask, "done": false});
                              });
                            },
                          ),
                        ),
                      );
                    },
                    confirmDismiss: (direction) async => true,
                    child: Card(
                      child: ListTile(
                        leading: Checkbox(
                          activeColor: Colors.green,
                          value: _tasks[index]["done"],
                          onChanged: (value){
                            setState(() {
                              _tasks[index]["done"] = value ?? false;
                            });
                          },
                        ),
                          title: Text(
                            _tasks[index]["title"],
                            style: TextStyle(
                              fontSize: 16,
                              decoration: _tasks[index]["done"]
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              color: Colors.red,
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                final deletedTask = _tasks[index]["title"]; // store before removing
                                await showDialog(
                                    context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text("You are about to delete ${_tasks[index]["title"]}"),
                                    content: Text("Are you sure?", style: TextStyle(fontSize: 18),),
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
                                                    _tasks.insert(index, {"id": DateTime.now().millisecondsSinceEpoch, "title": deletedTask, "done": false});
                                                  });
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text("Delete", style: TextStyle(color: Colors.red),),
                                      ),
                                    ],
                                  ),
                                );

                              },
                            ),
                            SizedBox(width: 6,),
                            IconButton(
                              onPressed: () => _editTask(index),
                              icon: Icon(Icons.edit),
                            )
                          ],
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
  Future<void> _editTask(int index) async {
    final current = _tasks[index]["title"] as String;
    final controller = TextEditingController(text: current);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Task"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Update task title",
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) Navigator.of(ctx).pop(trimmed);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isNotEmpty) {
                Navigator.of(ctx).pop(trimmed);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    // Update the task if a new title was provided
    if (newTitle != null && newTitle.isNotEmpty) {
      setState(() {
        _tasks[index]["title"] = newTitle;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task has been updated'),
        ),
      );
    }
  }}