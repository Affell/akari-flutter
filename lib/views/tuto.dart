import 'package:flutter/material.dart';

class Tuto extends StatelessWidget {
  const Tuto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to play ?'),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /*
Place light bulbs (circles) according to the following rules.
Light bulbs may be placed in any of the white squares, the number in the square shows how many light bulbs are next to it, vertically and horizontally.
Each light bulb illuminates from bulb to black square or outer frame in its row and column.
Every white square must be illuminated and a light bulb can not illuminate another light bulb.
                */
                Text("Objective :",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(
                    "The goal is very simple : you have to illuminate every tile by placing light bulbs in the grid."),
                SizedBox(height: 15),
                Text("Rules :",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(
                    "1. Light bulbs may be placed in any of the available squares (which is not covered by a wall)."),
                SizedBox(height: 10),
                Text(
                    "2. Some walls have number that shows exactly how many light bulbs must be next to it, vertically and horizontally."),
                SizedBox(height: 10),
                Text(
                    "3. Each light bulb illuminates from bulb to wall or outer frame in its row and column."),
                SizedBox(height: 10),
                Text("4. A light bulb can not illuminate another light bulb.")
              ]),
        ),
      ),
    );
  }
}
