import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/data.dart';
import 'edit.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>('tasks');
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xff794CFF),
      statusBarBrightness: Brightness.light));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final primaryTextColor = const Color(0xff1D2830);
    final secondaryTextColor = const Color(0xffAFBED0);
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.

          textTheme: GoogleFonts.poppinsTextTheme(
            const TextTheme(
              headline6: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: secondaryTextColor),
            iconColor: secondaryTextColor,
            border: InputBorder.none,
          ),
          colorScheme: ColorScheme.light(
            primary: const Color(0xff794CFF),
            primaryVariant: const Color(0xff5C0AFF),
            background: const Color(0xffF3F5F8),
            onSurface: primaryTextColor,
            onBackground: primaryTextColor,
            secondary: const Color(0xff794CFF),
            onSecondary: Colors.white,
            onTertiary: secondaryTextColor,
          ),
        ),
        home: const HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<Task> box = Hive.box<Task>('tasks');
    final themeData = Theme.of(context);
    final TextEditingController controller = TextEditingController();
    final ValueNotifier<String> searchKeyboardNotifier =
        ValueNotifier<String>('');
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditTaskScreen(
                      task: Task(),
                    )));
          },
          label: Row(
            children: [
              const Text('Add New Task'),
              const SizedBox(
                width: 4,
              ),
              const Icon(Icons.add_circle_outline_rounded),
            ],
          )),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 102,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  themeData.colorScheme.primary,
                  themeData.colorScheme.primaryVariant
                ]),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'To Do List',
                        style: themeData.textTheme.headline6!
                            .apply(color: themeData.colorScheme.onPrimary),
                      ),
                      Icon(
                        CupertinoIcons.alarm,
                        color: themeData.colorScheme.onPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 38,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: themeData.colorScheme.onPrimary,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ]),
                    child: TextField(
                        onChanged: (value) {
                          searchKeyboardNotifier.value =
                              controller.text; // @ToDo
                        },
                        controller: controller,
                        decoration: InputDecoration(
                          label: Text('Search tasks...'),
                          prefixIcon: Icon(CupertinoIcons.search),
                        )),
                  )
                ]),
              ),
            ),
            Expanded(
                child: ValueListenableBuilder<String>(
              valueListenable: searchKeyboardNotifier,
              builder: (context, value, child) {
                return ValueListenableBuilder<Box<Task>>(
                  valueListenable: box.listenable(),
                  builder: (context, box, child) {
                    final items;
                    if (controller.text.isEmpty) {
                      items = box.values.toList();
                    } else {
                      items = box.values
                          .where((task) => task.name.contains(controller.text))
                          .toList();
                    }
                    if (items.isNotEmpty) {
                      return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: items.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _fristRowBar(themeData, box);
                            } else {
                              final Task task = items[index - 1];
                              return TaskItem(task: task);
                            }
                          });
                    } else {
                      return const _EmptyList();
                    }
                  },
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  Row _fristRowBar(ThemeData themeData, Box<Task> box) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today',
              style: themeData.textTheme.headline6!.apply(fontSizeFactor: 0.8),
            ),
            Container(
              width: 50,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: themeData.colorScheme.primary,
              ),
            )
          ],
        ),
        MaterialButton(
          color: const Color(0xffEAEFF5),
          textColor: themeData.colorScheme.onTertiary,
          elevation: 0,
          onPressed: () {
            box.clear();
          },
          child: Row(
            children: [
              const Text('Delete All'),
              const SizedBox(
                width: 4,
              ),
              const Icon(
                CupertinoIcons.delete,
                size: 20,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/empty_state.svg",
          width: 120,
        ),
        const SizedBox(
          height: 12,
        ),
        const Text('Your task list is empty'),
      ],
    );
  }
}

class TaskItem extends StatefulWidget {
  const TaskItem({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final Color priorityColor;
    switch (widget.task.priority) {
      case Priority.high:
        priorityColor = const Color(0xff794CFF);
        break;
      case Priority.normal:
        priorityColor = const Color(0xffF09819);
        break;
      case Priority.low:
        priorityColor = const Color(0xff3BE1F1);
        break;
    }
    return InkWell(
      onTap: () {
        setState(() {
          widget.task.isDone = !widget.task.isDone;
          widget.task.save();
        });
      },
      onLongPress: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EditTaskScreen(
            task: widget.task,
          ),
        ));
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
        height: 84,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))
          ],
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        child: Row(
          children: [
            MyCheckBox(value: widget.task.isDone),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Text(
                overflow: TextOverflow.ellipsis,
                widget.task.name,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    decoration:
                        widget.task.isDone ? TextDecoration.lineThrough : null),
              ),
            ),
            IconButton(
                onPressed: () {
                  widget.task.delete();
                },
                icon: Icon(
                  Icons.delete_outline_outlined,
                  color: Colors.blueGrey,
                )),
            SizedBox(width: 8),
            Container(
              width: 8,
              height: 84,
              decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8))),
            )
          ],
        ),
      ),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  final bool value;

  const MyCheckBox({super.key, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: value
            ? null
            : Border.all(color: Theme.of(context).colorScheme.onTertiary),
        color: value ? Theme.of(context).colorScheme.primary : null,
      ),
      child: value
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            )
          : null,
    );
  }
}
