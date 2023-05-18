import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:to_do_list/data/repo/repository.dart';

import '../../../data/data.dart';

part 'task_list_event.dart';
part 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final Repository<Task> repository;
  TaskListBloc(this.repository) : super(TaskListInitial()) {
    on<TaskListEvent>((event, emit) async {
      final String searchText;
 
      if (event is TaskListStarted || event is TaskListSerarch) {
        emit(TaskListLoading());
        if (event is TaskListSerarch) {
          searchText = event.searchText;
        } else {
          searchText = '';
        }

        try {
          final items = await repository.getAll(searchKeyword: searchText);
          if (items.isNotEmpty) {
            emit(TaskListSuccess(items));
          } else {
            emit(TaskListEmpty());
          }
        } catch (e) {
          emit(TaskListError("UnKnown Error."));
        }
      } else if (event is TaskListDeleteAll) {
        await repository.deleteAll();
        emit(TaskListEmpty());
      }
    });
  }
}
