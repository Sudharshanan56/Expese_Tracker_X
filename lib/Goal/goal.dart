import 'package:flutter/material.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  double totalBalance = 1000.0; // Fixed total balance shown at top

  // Goal model: category, priority, amountNeeded
  final List<Map<String, dynamic>> goals = [];

  final List<String> priorities = ['Must', 'Need', 'Want'];

  void _addGoal() {
    String category = '';
    String? selectedPriority = priorities[0];
    String amountText = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Goal"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Category Name",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => category = value.trim(),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Priority",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedPriority,
                      items:
                          priorities
                              .map(
                                (p) =>
                                    DropdownMenuItem(value: p, child: Text(p)),
                              )
                              .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedPriority = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Amount Needed",
                        border: OutlineInputBorder(),
                        prefixText: "\$ ",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => amountText = value.trim(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (category.isEmpty ||
                    selectedPriority == null ||
                    amountText.isEmpty) {
                  return;
                }
                final amount = double.tryParse(amountText);
                if (amount == null || amount <= 0) return;
                setState(() {
                  goals.add({
                    "category": category,
                    "priority": selectedPriority,
                    "amountNeeded": amount,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Goals"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Always show fixed total balance
            Text(
              "Total Balance: \$${totalBalance.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child:
                  goals.isEmpty
                      ? const Center(child: Text("No goals added yet."))
                      : ListView.builder(
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          final goal = goals[index];
                          bool isFunded =
                              totalBalance >=
                              goal["amountNeeded"]; // ✅ Compare only
                          return Card(
                            color: isFunded ? Colors.green.shade100 : null,
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    goal["priority"] == "Must"
                                        ? Colors.red
                                        : goal["priority"] == "Need"
                                        ? Colors.orange
                                        : Colors.blue,
                                child: Text(
                                  goal["priority"][0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(goal["category"]),
                              subtitle: Text("Priority: ${goal["priority"]}"),
                              trailing: Text(
                                "\$${goal["amountNeeded"].toStringAsFixed(2)}",
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGoal,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        tooltip: "Add Goal",
      ),
    );
  }
}
