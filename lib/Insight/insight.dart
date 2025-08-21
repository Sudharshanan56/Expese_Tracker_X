import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InsightScreen(),
    );
  }
}

class InsightScreen extends StatefulWidget {
  @override
  _InsightScreenState createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  List<Map<String, dynamic>> categories = [
    {"title": "Transaction", "amount": 1890.0, "color": Colors.blue},
    {"title": "Groceries", "amount": 1890.0, "color": Colors.green},
    {"title": "Payments & Bills", "amount": 1890.0, "color": Colors.teal},
    {"title": "Entertainment", "amount": 1200.0, "color": Colors.orange},
  ];

  int? touchedIndex;

  double get totalLimit {
    return categories.fold(0, (sum, cat) => sum + cat["amount"]);
  }

  void removeCategory(int index) {
    setState(() {
      categories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text("Insight", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Donut + Legend side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Donut Chart
                SizedBox(
                  height: 220,
                  width: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: categories.asMap().entries.map((entry) {
                            int index = entry.key;
                            var cat = entry.value;
                            return PieChartSectionData(
                              color: cat["color"],
                              value: cat["amount"],
                              radius: touchedIndex == index ? 60 : 50,
                              showTitle: false,
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                setState(() {
                                  touchedIndex = null; // safely reset
                                });
                                return;
                              }
                              setState(() {
                                touchedIndex = response
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            touchedIndex == null
                                ? "₹ ${totalLimit.toStringAsFixed(0)}"
                                : "${categories[touchedIndex!]["title"]}\n₹ ${categories[touchedIndex!]["amount"].toStringAsFixed(0)}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (touchedIndex == null)
                            const Text("your limit",
                                style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Legend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cat["color"],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cat["title"],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Top Categories
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Top Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            ...categories.asMap().entries.map((entry) {
              int index = entry.key;
              var cat = entry.value;
              double percent = totalLimit == 0 ? 0 : cat["amount"] / totalLimit;

              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => removeCategory(index),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cat["color"].withOpacity(0.2),
                      child: Icon(Icons.circle, color: cat["color"], size: 16),
                    ),
                    title: Text(cat["title"]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: percent,
                          color: cat["color"],
                          backgroundColor: Colors.grey.shade200,
                        ),
                        const SizedBox(height: 4),
                        Text("${(percent * 100).toStringAsFixed(0)}%"),
                      ],
                    ),
                    trailing: Text(
                      "₹ ${cat["amount"].toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCategory = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCategoryScreen(
                existingColors:
                    categories.map((e) => e["color"] as Color).toList(),
              ),
            ),
          );

          if (newCategory != null) {
            setState(() {
              categories.add(newCategory);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Add Category Screen
class AddCategoryScreen extends StatefulWidget {
  final List<Color> existingColors;
  AddCategoryScreen({required this.existingColors});

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final List<Color> availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.brown,
    Colors.indigo,
    Colors.pink,
  ];

  Color getRandomUniqueColor() {
    final unusedColors = availableColors
        .where((c) => !widget.existingColors.contains(c))
        .toList();
    if (unusedColors.isEmpty) {
      return Colors.grey; // fallback if all colors used
    }
    return unusedColors[Random().nextInt(unusedColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Category")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Category Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount Spent"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    "title": nameController.text,
                    "amount": double.parse(amountController.text),
                    "color": getRandomUniqueColor(),
                  });
                }
              },
              child: const Text("Confirm"),
            )
          ],
        ),
      ),
    );
  }
}
