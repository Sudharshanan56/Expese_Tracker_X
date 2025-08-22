// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class InsightScreen extends StatefulWidget {
//   @override
//   _InsightScreenState createState() => _InsightScreenState();
// }

// class _InsightScreenState extends State<InsightScreen> {
//   int? touchedIndex;
//   final String uid = FirebaseAuth.instance.currentUser!.uid;

//   // 🔹 Get color for categories
//   Color _getCategoryColor(String title) {
//     switch (title.toLowerCase()) {
//       case "groceries":
//         return Colors.green;
//       case "food":
//         return Colors.orange;
//       case "entertainment":
//         return Colors.purple;
//       case "payments & bills":
//         return Colors.teal;
//       default:
//         return Colors.blueGrey;
//     }
//   }

//   // 🔹 Convert string to TitleCase (first letter caps)
//   String _toTitleCase(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1).toLowerCase();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text("Insight", style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream:
//             FirebaseFirestore.instance.collection("users").doc(uid).snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(
//               child: Text(
//                 "User data not found",
//                 style: TextStyle(color: Colors.red),
//               ),
//             );
//           }

//           var userData = snapshot.data!.data() as Map<String, dynamic>;
//           double balance = (userData["balance"] ?? 0).toDouble();

//           return StreamBuilder<QuerySnapshot>(
//             stream:
//                 FirebaseFirestore.instance
//                     .collection("users")
//                     .doc(uid)
//                     .collection("transactions")
//                     .snapshots(),
//             builder: (context, catSnapshot) {
//               if (catSnapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (!catSnapshot.hasData || catSnapshot.data!.docs.isEmpty) {
//                 return const Center(child: Text("No categories found"));
//               }

//               // 🔹 Step 1: Collect raw transactions
//               List<Map<String, dynamic>> rawTransactions =
//                   catSnapshot.data!.docs.map((doc) {
//                     var data = doc.data() as Map<String, dynamic>;
//                     return {
//                       "title": data["category"] ?? "Unknown",
//                       "amount": (data["amount"] ?? 0).toDouble(),
//                     };
//                   }).toList();

//               // 🔹 Step 2: Group by lowercase category
//               Map<String, double> grouped = {};
//               for (var tx in rawTransactions) {
//                 String cat =
//                     (tx["title"] ?? "Unknown").toString().toLowerCase();
//                 double amt = tx["amount"];
//                 grouped[cat] = (grouped[cat] ?? 0) + amt;
//               }

//               // 🔹 Step 3: Convert to final categories list
//               var categories =
//                   grouped.entries.map((entry) {
//                     String displayTitle = _toTitleCase(entry.key);
//                     return {
//                       "title": displayTitle,
//                       "amount": entry.value,
//                       "color": _getCategoryColor(entry.key),
//                     };
//                   }).toList();

//               return SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     // Donut + Legend
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         // Donut Chart
//                         SizedBox(
//                           height: 220,
//                           width: 220,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               PieChart(
//                                 PieChartData(
//                                   sections:
//                                       categories.asMap().entries.map((entry) {
//                                         int index = entry.key;
//                                         var cat = entry.value;
//                                         return PieChartSectionData(
//                                           color: cat["color"] as Color,
//                                           value: cat["amount"] as double,
//                                           radius:
//                                               touchedIndex == index ? 60 : 50,
//                                           showTitle: false,
//                                         );
//                                       }).toList(),
//                                   sectionsSpace: 2,
//                                   centerSpaceRadius: 60,
//                                   pieTouchData: PieTouchData(
//                                     touchCallback: (event, response) {
//                                       if (!event.isInterestedForInteractions ||
//                                           response == null ||
//                                           response.touchedSection == null) {
//                                         setState(() => touchedIndex = null);
//                                         return;
//                                       }
//                                       setState(() {
//                                         touchedIndex =
//                                             response
//                                                 .touchedSection!
//                                                 .touchedSectionIndex;
//                                       });
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               // Center Text
//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     "₹ ${balance.toStringAsFixed(0)}",
//                                     style: const TextStyle(
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   const Text(
//                                     "Balance",
//                                     style: TextStyle(color: Colors.grey),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 20),

//                         // Legend
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children:
//                                 categories.map((cat) {
//                                   return Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 4,
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Container(
//                                           width: 12,
//                                           height: 12,
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: cat["color"] as Color,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Expanded(
//                                           child: Text(
//                                             cat["title"] as String,
//                                             style: const TextStyle(
//                                               fontSize: 14,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 }).toList(),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 20),

//                     // Transactions List
//                     const Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "Transactions",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),

//                     ...categories.map((cat) {
//                       double percent =
//                           balance == 0
//                               ? 0
//                               : ((cat["amount"] as double) / balance);
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         elevation: 1,
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             backgroundColor: (cat["color"] as Color)
//                                 .withOpacity(0.2),
//                             child: Icon(
//                               Icons.category,
//                               color: cat["color"] as Color,
//                             ),
//                           ),
//                           title: Text(cat["title"] as String),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               LinearProgressIndicator(
//                                 value: percent > 1 ? 1 : percent,
//                                 color: cat["color"] as Color,
//                                 backgroundColor: Colors.grey.shade200,
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 "${(percent * 100).toStringAsFixed(0)}% of balance",
//                               ),
//                             ],
//                           ),
//                           trailing: Text(
//                             "₹ ${cat["amount"] as double}.toStringAsFixed(0)}",
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightScreen extends StatefulWidget {
  @override
  _InsightScreenState createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  int? touchedIndex;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // 🔹 Get color for categories
  Color _getCategoryColor(String title) {
    switch (title.toLowerCase()) {
      case "groceries":
        return Colors.green;
      case "food":
        return Colors.orange;
      case "entertainment":
        return Colors.purple;
      case "payments & bills":
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  // 🔹 Convert string to TitleCase (first letter caps)
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Insight", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("transactions")
                .snapshots(),
        builder: (context, catSnapshot) {
          if (catSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!catSnapshot.hasData || catSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No transactions found"));
          }

          // 🔹 Step 1: Collect raw transactions
          List<Map<String, dynamic>> rawTransactions =
              catSnapshot.data!.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return {
                  "title": data["category"] ?? "Unknown",
                  "amount": (data["amount"] ?? 0).toDouble(),
                };
              }).toList();

          // 🔹 Step 2: Group by lowercase category
          Map<String, double> grouped = {};
          for (var tx in rawTransactions) {
            String cat = (tx["title"] ?? "Unknown").toString().toLowerCase();
            double amt = tx["amount"];
            grouped[cat] = (grouped[cat] ?? 0) + amt;
          }

          // 🔹 Step 3: Convert to final categories list
          var categories =
              grouped.entries.map((entry) {
                String displayTitle = _toTitleCase(entry.key);
                return {
                  "title": displayTitle,
                  "amount": entry.value,
                  "color": _getCategoryColor(entry.key),
                };
              }).toList();

          // 🔹 Step 4: Calculate total expense
          double totalExpense = categories.fold(
            0,
            (sum, cat) => sum + (cat["amount"] as double),
          );

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
                              sections:
                                  categories.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    var cat = entry.value;
                                    return PieChartSectionData(
                                      color: cat["color"] as Color,
                                      value: cat["amount"] as double,
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
                                    touchedIndex =
                                        response
                                            .touchedSection!
                                            .touchedSectionIndex;
                                  });
                                },
                              ),
                            ),
                          ),
                          // Center Text
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "₹ ${totalExpense.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Total Expense",
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
                        children:
                            categories.map((cat) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: cat["color"] as Color,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        cat["title"] as String,
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

                // Transactions List
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Transactions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                ...categories.map((cat) {
                  double percent =
                      totalExpense == 0
                          ? 0
                          : ((cat["amount"] as double) / totalExpense);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 1,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (cat["color"] as Color).withOpacity(
                          0.2,
                        ),
                        child: Icon(
                          Icons.category,
                          color: cat["color"] as Color,
                        ),
                      ),
                      title: Text(cat["title"] as String),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: percent > 1 ? 1 : percent,
                            color: cat["color"] as Color,
                            backgroundColor: Colors.grey.shade200,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${(percent * 100).toStringAsFixed(0)}% of total",
                          ),
                        ],
                      ),
                      trailing: Text(
                        "₹ ${(cat["amount"] as double).toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
