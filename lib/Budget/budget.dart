import 'package:expense_tracker_x/Budget/set_budget.dart';
import 'package:expense_tracker_x/Insight/insight.dart';
import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Map<String, dynamic>> budgets = [
    {
      "title": "Shopping",
      "expense": 250.0,
      "limit": 900.0,
      "color": Colors.green,
    },
    {
      "title": "Food",
      "expense": 900.0,
      "limit": 1200.0,
      "color": Colors.orange,
    },
    {
      "title": "Holidays",
      "expense": 2500.0,
      "limit": 2000.0,
      "color": Colors.red,
    },
  ];

  Color getBarColor(double expense, double limit) {
    if (expense > limit) return Colors.red;
    if (expense > limit * 0.75) return Colors.orange;
    return Colors.green;
  }

  String getStatusText(double expense, double limit) {
    if (expense > limit)
      return "Overspend \$${expense.toInt()}/${limit.toInt()}";
    if (expense > limit * 0.75)
      return "Risk of overspend \$${expense.toInt()}/${limit.toInt()}";
    return "Expense \$${expense.toInt()}/${limit.toInt()}";
  }

  double get totalLimit => budgets.fold(0, (sum, b) => sum + b["limit"]);
  double get totalExpense => budgets.fold(0, (sum, b) => sum + b["expense"]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budgets"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => InsightScreen(
                        // budgets: budgets,
                        // totalLimit: totalLimit,
                        // totalExpense: totalExpense,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Periodic",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final budget = budgets[index];
                  double expense = budget["expense"];
                  double limit = budget["limit"];
                  double percent = (expense / limit).clamp(0.0, 1.0);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                budget["title"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                getStatusText(expense, limit),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: getBarColor(expense, limit),
                                ),
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
                    MaterialPageRoute(builder: (_) => SetBudgetScreen()),
                  );

                  if (newBudget != null) {
                    setState(() {
                      budgets.add(newBudget);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Set budget",
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
