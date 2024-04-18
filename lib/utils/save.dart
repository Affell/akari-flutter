import 'dart:convert';

import 'package:akari/main.dart';
import 'package:akari/models/action.dart';
import 'package:akari/models/grid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

enum SaveMode {
  classic(tableName: "ongoing"),
  archive(tableName: "completed");

  const SaveMode({required this.tableName});

  final String tableName;
}

void saveGame(Grid game, SaveMode mode) {
  if (databaseManager.database != null) {
    // Translate arrays into json encoded strings
    String startGridText = jsonEncode(game.startGrid);
    String lightsText =
        jsonEncode(game.lights.map((l) => [l.item1, l.item2]).toList());

    Map<String, Object> values = {
      "creation_time": game.creationTime,
      "difficulty": game.difficulty,
      "size": game.gridSize,
      "time_spent": game.time,
      "start_grid": startGridText,
      "lights": lightsText
    };

    if (mode == SaveMode.classic) {
      values["actions"] =
          jsonEncode(game.actions.map((a) => a.toMap()).toList());
    }
    print(values);

    // Insert or Update
    databaseManager.database!.insert(mode.tableName, values,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

Future<Grid?> loadGame(int creationTime, SaveMode mode) async {
  if (databaseManager.database != null) {
    List<String> columns = [
      "difficulty",
      "size",
      "time_spent",
      "start_grid",
      "lights"
    ];
    if (mode == SaveMode.classic) columns.add("actions");
    List<Map<String, Object?>> results = await databaseManager.database!.query(
        mode.tableName,
        columns: columns,
        where: "creation_time = ?",
        whereArgs: [creationTime]);

    if (results.length == 1) {
      int time = results[0]["time_spend"] as int;
      int difficulty = results[0]["difficulty"] as int;
      int gridSize = results[0]["size"] as int;
      List<List<int>> startGrid = jsonDecode(results[0]["start_grid"] as String)
          .map<List<int>>((l) => List<int>.from(l))
          .toList();
      List<Tuple2<int, int>> lights = jsonDecode(results[0]["lights"] as String)
          .map<List<int>>((l) => List<int>.from(l))
          .toList()
          .map<Tuple2<int, int>>((e) => Tuple2(e[0] as int, e[1] as int))
          .toList();

      List<GridAction> actions =
          jsonDecode((results[0]["actions"] ?? "[]") as String)
              .map((map) => GridAction.fromMap(map))
              .toList()
              .whereType<GridAction>()
              .toList();

      return Grid(
          creationTime, time, difficulty, gridSize, startGrid, lights, actions);
    }
  }

  return null;
}



Future<List<Map<String, Object?>>> getAllGames(SaveMode mode) async {
  if (databaseManager.database != null) {
    return await databaseManager.database!.query(mode.tableName);
  }
  return [];
}
