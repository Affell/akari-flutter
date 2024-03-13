enum GridActionType {
  add(identifier: "a"),
  remove(identifier: "r");

  const GridActionType({required this.identifier});

  final String identifier;

  static GridActionType? fromIdentifier(String identifier) {
    for (var type in values) {
      if (type.identifier == identifier) {
        return type;
      }
    }
    return null;
  }
}

class GridAction {
  const GridAction(this.type, this.x, this.y);

  final GridActionType type;
  final int x, y;

  String getLine() {
    return "${type.identifier} ${x.toString()} ${y.toString()}";
  }

  Map<String, Object> toMap() {
    return {"type": type.identifier, "x": x, "y": y};
  }

  static GridAction? fromMap(Map<String, Object> map) {
    // Parse ActionType
    GridActionType? type = GridActionType.fromIdentifier(map["type"] as String);
    if (type == null) {
      return null;
    }

    // Parse coordinates
    int x = map["x"] as int;
    int y = map["y"] as int;

    return GridAction(type, x, y);
  }
}
