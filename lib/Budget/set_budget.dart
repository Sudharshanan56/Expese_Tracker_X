// import 'package:flutter/material.dart';

// class SetBudgetScreen extends StatefulWidget {
//   @override
//   State<SetBudgetScreen> createState() => _SetBudgetScreenState();
// }

// class _SetBudgetScreenState extends State<SetBudgetScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController expenseController = TextEditingController();
//   final TextEditingController limitController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Set Budget"),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: titleController,
//                 decoration: const InputDecoration(
//                   labelText: "Category Title",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) => v!.isEmpty ? "Enter category name" : null,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: expenseController,
//                 decoration: const InputDecoration(
//                   labelText: "Expense",
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (v) => v!.isEmpty ? "Enter expense amount" : null,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: limitController,
//                 decoration: const InputDecoration(
//                   labelText: "Budget Limit",
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (v) => v!.isEmpty ? "Enter budget limit" : null,
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       final newBudget = {
//                         "title": titleController.text,
//                         "expense":
//                             double.tryParse(expenseController.text) ?? 0.0,
//                         "limit": double.tryParse(limitController.text) ?? 0.0,
//                         "color":
//                             Colors.primaries[DateTime.now().millisecond %
//                                 Colors.primaries.length],
//                       };
//                       Navigator.pop(context, newBudget);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                   ),
//                   child: const Text(
//                     "Save",
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class SetBudgetScreen extends StatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController limitController = TextEditingController();

  // Predefined categories
  final List<String> categories = [
    "Food",
    "Shopping",
    "Holidays",
    "Transport",
    "Entertainment",
    "Other",
  ];

  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,title: const Text("Set Budget")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Category",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Dropdown for category
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items:
                  categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            // Show custom category field only if "Other" is selected
            if (selectedCategory == "Other") ...[
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: "Custom Category",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Limit input
            TextField(
              controller: limitController,
              decoration: const InputDecoration(
                labelText: "Limit (₹)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String finalCategory =
                      selectedCategory == "Other"
                          ? categoryController.text.trim()
                          : selectedCategory ?? "";

                  if (finalCategory.isNotEmpty &&
                      limitController.text.isNotEmpty) {
                    Navigator.pop(context, {
                      "title": finalCategory, // 🔹 save lowercase
                      "limit": double.parse(limitController.text.trim()),
                    });
                  }
                },
                child: const Text("Save Budget"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
