import 'package:hive_flutter/adapters.dart';
part 'data.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  int id = -1;
  @HiveField(0)
  String name = "";
  @HiveField(1)
  bool isDone = false;
  @HiveField(2)
  Priority priority = Priority.low;
}

@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  high,
  @HiveField(1)
  normal,
  @HiveField(2)
  low,
}
