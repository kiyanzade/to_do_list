import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:provider/provider.dart';
import 'package:to_do_list/data/repo/repository.dart';
import 'package:to_do_list/screens/home/bloc/task_list_bloc.dart';
import 'package:to_do_list/widgets.dart';

import '../../data/data.dart';
import '../edit/edit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(
                task: Task(),
              ),
            ),
          );
        },
        label: Row(
          children: [
            const Text('Add New Task'),
            const SizedBox(
              width: 4,
            ),
            const Icon(Icons.add_circle_outline_rounded),
          ],
        ),
      ),
      body: BlocProvider<TaskListBloc>(
        create: (context) => TaskListBloc(context.read<Repository<Task>>()),
        child: SafeArea(
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
                            context
                                .read<TaskListBloc>()
                                .add(TaskListSerarch(value));
                          },
                          controller: controller,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            label: Text('Search tasks...'),
                            prefixIcon: Icon(CupertinoIcons.search),
                          )),
                    )
                  ]),
                ),
              ),
              Expanded(
                child: Consumer<Repository<Task>>(
                  builder: (context, model, child) {
                    context.read<TaskListBloc>().add(TaskListStarted());
                    return BlocBuilder<TaskListBloc, TaskListState>(
                      builder: (context, state) {
                        if (state is TaskListSuccess) {
                          return taskList(state.items, themeData);
                        } else if (state is TaskListLoading ||
                            state is TaskListInitial) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is TaskListEmpty) {
                          return EmptyList();
                        } else if (state is TaskListError) {
                          return Center(child: Text(state.errorMessage));
                        } else {
                          throw Exception('state is not valid !');
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListView taskList(items, ThemeData themeData) {
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: themeData.textTheme.headline6!
                          .apply(fontSizeFactor: 0.8),
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
                    context.read<TaskListBloc>().add(TaskListDeleteAll());
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
          } else {
            final Task task = items[index - 1];
            return TaskItem(task: task);
          }
        });
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
