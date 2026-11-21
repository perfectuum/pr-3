import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = TextEditingController();
  final List<String> notes = [];
  final List<bool> important = [];
  int? editingIndex;
  double swipeDistance = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Заметки')),
        body: Column(
          children: [
            TextField(controller: controller),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;

                setState(() {
                  if (editingIndex == null) {
                    notes.add(controller.text);
                    important.add(false);
                  } else {
                    notes[editingIndex!] = controller.text;
                  }

                  controller.clear();
                  editingIndex = null;
                });
              },
              child: const Text('Сохранить'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: SingleChildScrollView(
                            child: Text(notes[index]),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Закрыть'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDoubleTap: () {
                      setState(() {
                        important[index] = true;
                      });
                    },
                    onLongPress: () {
                      editingIndex = index;
                      controller.text = notes[index];
                    },
                    onHorizontalDragStart: (details) {
                      swipeDistance = 0;
                    },
                    onHorizontalDragUpdate: (details) {
                      swipeDistance += details.delta.dx;
                    },
                    onHorizontalDragEnd: (details) {
                      setState(() {
                        if (swipeDistance < -50) {
                          notes.removeAt(index);
                          important.removeAt(index);

                          if (editingIndex == index) {
                            editingIndex = null;
                            controller.clear();
                          } else if (editingIndex != null &&
                              index < editingIndex!) {
                            editingIndex = editingIndex! - 1;
                          }
                        } else if (swipeDistance > 50) {
                          important[index] = false;
                        }
                      });
                    },
                    child: ListTile(
                      tileColor: important[index] ? Colors.amber[100] : null,
                      title: Text(
                        notes[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}