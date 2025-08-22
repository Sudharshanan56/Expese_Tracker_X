import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'set_budget.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Color getBarColor(double expense, double limit) {
    if (expense > limit) return Colors.red;
    if (expense > limit * 0.75) return Colors.orange;
    return Colors.green;
  }

  String getStatusText(double expense, double limit) {
    if (expense > limit) {
      return "Overspend ₹${expense.toInt()}/${limit.toInt()}";
    }
    if (expense > limit * 0.75) {
      return "Risk ₹${expense.toInt()}/${limit.toInt()}";
    }
    return "Expense ₹${expense.toInt()}/${limit.toInt()}";
  }

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "food":
        return Icons.fastfood;
      case "shopping":
        return Icons.shopping_cart;
      case "holidays":
        return Icons.flight_takeoff;
      case "transport":
        return Icons.directions_bus;
      case "entertainment":
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Budgets"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Budgets",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Fetch budgets from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(uid)
                        .collection("budgets")
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No budgets found"));
                  }

                  final budgets = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      var budget = budgets[index];
                      String category = budget.id;
                      double expense = budget["expense"] * 1.0;
                      double limit = budget["limit"] * 1.0;
                      double percent = (expense / limit).clamp(0.0, 1.0);

                      return Dismissible(
                        key: Key(budget.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .collection("budgets")
                              .doc(budget.id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Budget '${budget.id}' deleted"),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          getCategoryIcon(category),
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          category,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          getStatusText(expense, limit),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: getBarColor(expense, limit),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(uid)
                                                .collection("budgets")
                                                .doc(budget.id)
                                                .delete();

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Budget '${budget.id}' deleted",
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    minHeight: 12,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      getBarColor(expense, limit),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Add budget button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newBudget = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SetBudgetScreen()),
                  );

                  if (newBudget != null) {
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(uid)
                        .collection("budgets")
                        .doc(newBudget["title"]) // use category name as doc id
                        .set({
                          "limit": newBudget["limit"],
                          "expense": 0, // default
                        });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Set Budget",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
