part of 'task_list_bloc.dart';

@immutable
abstract class TaskListEvent {}

class TaskListStarted extends TaskListEvent{}

class TaskListSerarch extends TaskListEvent{
  final String searchText;

  TaskListSerarch(this.searchText);
}

class TaskListDeleteAll extends TaskListEvent{}
