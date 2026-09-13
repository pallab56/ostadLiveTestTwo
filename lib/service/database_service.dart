import 'package:ostadlivetesttwo/models/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseServices {
  static final DatabaseServices instance = DatabaseServices._constructor();

  DatabaseServices._constructor();
  final String _taskTableName = "tasks";
  final String _tasksIdColumnName = "id";
  final String _tasksContentColumnName = "content";
  final String _tasksStatusColumnName = "status";
  Database? _db;
  Future<Database?> get database async {
    if (_db != null) return _db!;

    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    
    final databaseDirPath = await getDatabasesPath();

    
    
    final databasePath = join(databaseDirPath, 'master_db.db');

    
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_taskTableName(
          $_tasksIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
          $_tasksContentColumnName TEXT NOT NULL,
          $_tasksStatusColumnName INTEGER NOT NULL
          )
          ''');
      },
    );
    return database;
  }

  void addTask(String content) async {
    final db = await database;
    await db!.insert(_taskTableName, {
      _tasksContentColumnName: content,
      _tasksStatusColumnName: 0,
    });
  }

  Future<List<Task>?> getTasks() async {
    final db = await database;
    final data = await db!.query(_taskTableName);
    List<Task> list = data
        .map(
          (e) => Task(
            status: e['status'] as int,
            id: e['id'] as int,
            content: e['content'] as String,
          ),
        )
        .toList();
    return list;
  }
 

  void updateTaskStatus(int id, int status) async {
    final db = await database;
    await db!.update(
      _taskTableName,
      {_tasksStatusColumnName: status},
      where: 'id=?',
      whereArgs: [id],
    );
  }

  void deleteTask(int id) async {
    final db = await database;
    await db!.delete(_taskTableName, where: 'id=?', whereArgs: [id]);
  }

 Future<List<Task>?> filterdTasks({String searchQuery = ''}) async {
  final db = await database;
  final data = await db!.query(_taskTableName);

  final list = data
      .map(
        (e) => Task(
          status: e['status'] as int,
          id: e['id'] as int,
          content: e['content'] as String,
        ),
      )
      .toList();

  final query = searchQuery.trim().toLowerCase();

  final filteredList = query.isEmpty
      ? list
      : list
          .where((task) => task.content.trim().toLowerCase().contains(query))
          .toList();

  return filteredList;
}

}