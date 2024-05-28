import 'package:flutter/material.dart';

class Tuto extends StatelessWidget {
  const Tuto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to play ?'),
      ),
      body: SingleChildScrollView(
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
                const Text("Objective :",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text(
                    "The goal is very simple : you have to illuminate every tile by placing light bulbs in the grid."),
                const SizedBox(height: 15),
                const Text("Rules :",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text(
                    "1. Light bulbs may be placed in any of the available squares (which is not covered by a wall)."),
                const SizedBox(height: 10),
                const Text(
                    "2. Some walls have number that shows exactly how many light bulbs must be next to it, vertically and horizontally."),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/images/rule2_1.png',
                          width: 70,
                        ),
                        const Icon(Icons.check, color: Colors.green)
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/images/rule2_2.png',
                          width: 70,
                        ),
                        const Icon(Icons.close, color: Colors.red)
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/images/rule2_3.png',
                          width: 70,
                        ),
                        const Icon(Icons.close, color: Colors.red)
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                    "3. Each light bulb illuminates from bulb to wall or outer frame in its row and column."),
                const SizedBox(height: 10),
                const Text(
                    "4. A light bulb can not illuminate another light bulb."),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/images/rule3_1.png',
                          width: 70,
                        ),
                        const Icon(Icons.check, color: Colors.green)
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/images/rule3_2.png',
                          width: 70,
                        ),
                        const Icon(Icons.close, color: Colors.red)
                      ],
                    ),
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}
