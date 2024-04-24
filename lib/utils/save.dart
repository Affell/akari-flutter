import 'dart:convert';
import 'package:akari/main.dart';
import 'package:akari/models/grid.dart';
import 'package:sqflite/sqflite.dart';

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
    String pastActionsText =
        jsonEncode(game.pastActions.map((a) => [a.item1, a.item2]).toList());
    String futureActionsText =
        jsonEncode(game.futureActions.map((a) => [a.item1, a.item2]).toList());

    Map<String, Object> values = {
      "creation_time": game.creationTime,
      "difficulty": game.difficulty,
      "size": game.gridSize,
      "time_spent": game.time,
      "start_grid": startGridText,
      "lights": lightsText,
      "actions_passees": pastActionsText,
      "actions_futures": futureActionsText
    };

    // Insert or Update
    databaseManager.database!.insert(mode.tableName, values,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}



Future<List<Map<String, Object?>>> getAllGames(SaveMode mode) async {
  if (databaseManager.database != null) {
    return await databaseManager.database!.query(mode.tableName);
  }
  return [];
}


void deleteGame(int creation_time, SaveMode mode) {
  if (databaseManager.database != null) {
    databaseManager.database!.delete(
      mode.tableName,
      where: 'creation_time = ?',
      whereArgs: [creation_time],
    );
  }
}