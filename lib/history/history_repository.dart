import 'package:deep_app/task/task.dart';
import 'package:deep_app/utils/offline_storage.dart';


class HistoryRepository{

  Future<List<Task>> getTasks() async{
    var taskslist = await OfflineStorage.getList();
    return taskslist.tasks;
  }

  Future<Task> addTask(List <String> image_paths, Results results) async{
    var taskslist = await OfflineStorage.getList();
    var id = 0;
    for(Task t in taskslist.tasks){
      if(t.id > id){
        id = t.id;
      }
    }
    id = id + 1;
    final task = Task(id: id, image_paths: image_paths, results: results);
    taskslist.tasks.add(task);
    OfflineStorage.putList(taskslist);
    return task;
  }

  Future<bool> removeTask(int id) async{
    var taskslist = await OfflineStorage.getList();
    for(Task t in taskslist.tasks){
      if(t.id == id){
        taskslist.tasks.remove(t);
        OfflineStorage.putList(taskslist);
        return true;
      }
    }
    return false;
  }
}