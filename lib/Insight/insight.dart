import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
  final String uid = FirebaseAuth.instance.currentUser!.uid;

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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("users").doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Balance not found", style: TextStyle(color: Colors.red)));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          double balance = (data["balance"] ?? 0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Donut + Legend
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
                                    setState(() => touchedIndex = null);
                                    return;
                                  }
                                  setState(() {
                                    touchedIndex = response.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                            ),
                          ),
                          // Center Text (Always Balance)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "₹ ${balance.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Balance",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
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
                                  child: Text(cat["title"], style: const TextStyle(fontSize: 14)),
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
                    "Transactions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                ...categories.asMap().entries.map((entry) {
                  int index = entry.key;
                  var cat = entry.value;

                  // % of category spend from BALANCE
                  double percent = balance == 0 ? 0 : (cat["amount"] / balance);

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
                              value: percent > 1 ? 1 : percent, // avoid overflow >100%
                              color: cat["color"],
                              backgroundColor: Colors.grey.shade200,
                            ),
                            const SizedBox(height: 4),
                            Text("${(percent * 100).toStringAsFixed(0)}% of balance"),
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
          );
        },
      ),
    );
  }
}
