import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/main.dart';

import 'data.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.task.name);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.surface,
        foregroundColor: themeData.colorScheme.onSurface,
        title: const Text('Edit Task'),
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Row(
          children: [
            const Text('Save Changes'),
            const SizedBox(
              width: 8,
            ),
            const Icon(Icons.save),
          ],
        ),
        onPressed: () {
          widget.task.name = _controller.text;
          widget.task.priority = widget.task.priority;
          if (widget.task.isInBox) {
            widget.task.save();
          } else {
            final Box<Task> box = Hive.box('tasks');
            box.add(widget.task);
          }

          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Flexible(
                flex: 1,
                child: _PriorityCheckBox(
                  onTap: () {
                    setState(() {
                      widget.task.priority = Priority.high;
                    });
                  },
                  label: 'High',
                  color: const Color(0xff794CFF),
                  isSelected: widget.task.priority == Priority.high,
                )),
            const SizedBox(width: 8),
            Flexible(
                flex: 1,
                child: _PriorityCheckBox(
                  onTap: () {
                    setState(() {
                      widget.task.priority = Priority.normal;
                    });
                  },
                  label: 'Normal',
                  color: const Color(0xffF09819),
                  isSelected: widget.task.priority == Priority.normal,
                )),
            const SizedBox(width: 8),
            Flexible(
                flex: 1,
                child: _PriorityCheckBox(
                  onTap: () {
                    setState(() {
                      widget.task.priority = Priority.low;
                    });
                  },
                  label: 'Low',
                  color: const Color(0xff3BE1F1),
                  isSelected: widget.task.priority == Priority.low,
                )),
          ]),
          TextField(
            controller: _controller,
            decoration:
                const InputDecoration(label: Text('Add a task for today...')),
          )
        ]),
      ),
    );
  }
}

class _PriorityCheckBox extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final Function() onTap;
  const _PriorityCheckBox({
    super.key,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                width: 2,
                color: themeData.colorScheme.onTertiary.withOpacity(0.5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text(label)),
            const SizedBox(
              width: 8,
            ),
            _CheckBoxPropertyShape(
              color: color,
              isSelected: isSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckBoxPropertyShape extends StatelessWidget {
  final Color color;
  final bool isSelected;

  const _CheckBoxPropertyShape(
      {super.key, required this.color, required this.isSelected});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(12), color: color),
      child: isSelected
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            )
          : null,
    );
  }
}
