import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_x/Authentication/phone.dart';
import 'package:expense_tracker_x/Calender/calender.dart';
import 'package:expense_tracker_x/Goal/goal.dart';
import 'package:expense_tracker_x/Notification/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userName;
  String? userEmail;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  final List<String> categories = [
    "Transactions",
    "Groceries",
    "Payment & Bills",
    "Entertainment",
    "Food",
    "Other",
  ];

  String? selectedCategory;
  final TextEditingController customCategoryController =
      TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      setState(() {
        userName = doc['name'];
        userEmail = doc['email'];
      });
    } else {
      setState(() {
        userName = user.displayName ?? "No Name";
        userEmail = user.email ?? "No Email";
      });
    }
  }

 Future<void> addTransaction(String category, int amount, {DateTime? customDate}) async {
  // Save transaction in "transactions"
  await _firestore
      .collection("users")
      .doc(uid)
      .collection("transactions")
      .add({
        "category": category,
        "amount": amount,
        "timestamp": customDate != null
            ? Timestamp.fromDate(customDate)
            : FieldValue.serverTimestamp(),
      });

  // Update budget if exists
  DocumentReference budgetRef = _firestore
      .collection("users")
      .doc(uid)
      .collection("budgets")
      .doc(category);

  DocumentSnapshot budgetSnap = await budgetRef.get();
  if (budgetSnap.exists) {
    await budgetRef.update({"expense": FieldValue.increment(amount)});
  }

  // ✅ Subtract from balance
  DocumentReference userRef = _firestore.collection("users").doc(uid);
  await userRef.update({
    "balance": FieldValue.increment(-amount),
  });
}


  Future<void> _showUpdateTransactionDialog(
    String docId,
    String currentCategory,
    int currentAmount,
  ) async {
    final TextEditingController updateAmountController = TextEditingController(
      text: currentAmount.toString(),
    );
    String? updateCategory = currentCategory;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: updateCategory,
                onChanged: (value) {
                  updateCategory = value;
                },
                items:
                    categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: updateAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Enter amount"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                int newAmount =
                    int.tryParse(updateAmountController.text.trim()) ?? 0;

                if (updateCategory == null || newAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid details")),
                  );
                  return;
                }

                await _firestore
                    .collection("users")
                    .doc(uid)
                    .collection("transactions")
                    .doc(docId)
                    .update({
                      "category": updateCategory,
                      "amount": newAmount,
                      "timestamp": FieldValue.serverTimestamp(),
                    });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Transaction updated")),
                );
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _showAddTransactionDialog(BuildContext context) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("Add Transaction"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             DropdownButtonFormField<String>(
  //               value: selectedCategory,
  //               hint: const Text("Select category"),
  //               onChanged: (value) {
  //                 setState(() {
  //                   selectedCategory = value;
  //                 });
  //               },
  //               items:
  //                   categories.map((cat) {
  //                     return DropdownMenuItem(value: cat, child: Text(cat));
  //                   }).toList(),
  //             ),
  //             if (selectedCategory == "Other") ...[
  //               const SizedBox(height: 10),
  //               TextField(
  //                 controller: customCategoryController,
  //                 decoration: const InputDecoration(
  //                   labelText: "Enter custom category",
  //                 ),
  //               ),
  //             ],
  //             const SizedBox(height: 10),
  //             TextField(
  //               controller: amountController,
  //               keyboardType: TextInputType.number,
  //               decoration: const InputDecoration(labelText: "Enter amount"),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("Cancel"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               final user = _auth.currentUser;
  //               if (user == null) return;

  //               String finalCategory = selectedCategory ?? "";
  //               if (finalCategory == "Other") {
  //                 finalCategory = customCategoryController.text.trim();
  //               }

  //               int amount = int.tryParse(amountController.text.trim()) ?? 0;

  //               if (finalCategory.isEmpty || amount <= 0) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(content: Text("Please enter valid details")),
  //                 );
  //                 return;
  //               }

  //               await addTransaction(finalCategory, amount);

  //               Navigator.pop(context);
  //               setState(() {
  //                 selectedCategory = null;
  //                 customCategoryController.clear();
  //                 amountController.clear();
  //               });

  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(
  //                   content: Text("Transaction added successfully"),
  //                 ),
  //               );
  //             },
  //             child: const Text("Save"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  DateTime? selectedDate;

  Future<void> _showAddTransactionDialog(BuildContext context) async {
  selectedDate = DateTime.now(); // default to today

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Add Transaction"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: const Text("Select category"),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              items: categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
            ),

            if (selectedCategory == "Other") ...[
              const SizedBox(height: 10),
              TextField(
                controller: customCategoryController,
                decoration: const InputDecoration(
                  labelText: "Enter custom category",
                ),
              ),
            ],

            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter amount"),
            ),

            const SizedBox(height: 10),

            // 📅 Date Picker
            Row(
              children: [
                Text(
                  selectedDate != null
                      ? "Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                      : "Pick a date",
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
  onPressed: () async {
    final user = _auth.currentUser;
    if (user == null) return;

    String finalCategory = selectedCategory ?? "";
    if (finalCategory == "Other") {
      finalCategory = customCategoryController.text.trim();
    }

    int amount = int.tryParse(amountController.text.trim()) ?? 0;

    if (finalCategory.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid details")),
      );
      return;
    }

    // ✅ Call addTransaction instead of direct .add()
    await addTransaction(finalCategory, amount, customDate: selectedDate);

    Navigator.pop(context);
    setState(() {
      selectedCategory = null;
      customCategoryController.clear();
      amountController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Transaction added successfully"),
      ),
    );
  },
  child: const Text("Save"),
),

        ],
      );
    },
  );
}


  // 🔹 Map category → icon
  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "transactions":
        return Icons.swap_horiz;
      case "groceries":
        return Icons.shopping_cart;
      case "payment & bills":
        return Icons.receipt_long;
      case "entertainment":
        return Icons.movie;
      case "food":
        return Icons.fastfood;
      case "other":
        return Icons.category;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? uid = user?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("No user logged in")));
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GoalPage()),
                  );
                },
                child: const Icon(
                  Icons.grade_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Drawer Header'),
              ),
              ListTile(
                leading: Icon(Icons.calendar_month),
                title: const Text('calender'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonthlyTransactionsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: const Text('Phone'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PhoneAuthScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Black Header
                  Container(
                    height: 400,
                    width: double.infinity,
                    color: Colors.black,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Text(
                              'Hello, ${userName ?? 'User'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),

                  // White Bottom List
                  Padding(
                    padding: const EdgeInsets.only(top: 300),
                    child: Container(
                      height: 500,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: StreamBuilder<QuerySnapshot>(
                          stream:
                              _firestore
                                  .collection("users")
                                  .doc(uid)
                                  .collection("transactions")
                                  .orderBy("timestamp", descending: true)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text("No transactions found"),
                              );
                            }

                            var transactions = snapshot.data!.docs;

                            return ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                var doc = transactions[index];
                                var data = doc.data() as Map<String, dynamic>;
                                String category =
                                    data["category"]?.toString() ?? "Other";
                                int amount = data["amount"] ?? 0;

                                return Dismissible(
                                  key: Key(doc.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (_) async {
  var data = doc.data() as Map<String, dynamic>;
  int amount = data["amount"] ?? 0;

  // 1️⃣ Add back the amount to balance
  await _firestore.collection("users").doc(uid).update({
    "balance": FieldValue.increment(amount),
  });

  // 2️⃣ Delete the transaction
  await _firestore
      .collection("users")
      .doc(uid)
      .collection("transactions")
      .doc(doc.id)
      .delete();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Transaction deleted and balance updated")),
  );
},

                                  child: ListTile(
                                    leading: Icon(
                                      getCategoryIcon(category),
                                      color: Colors.black,
                                    ),
                                    title: Text(
                                      category,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text("Tap to update"),
                                    trailing: Text(
                                      "₹ $amount",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () {
                                      _showUpdateTransactionDialog(
                                        doc.id,
                                        category,
                                        amount,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Balance Card
                  Positioned(
                    top: 150,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.green,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Current Balance",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          StreamBuilder<DocumentSnapshot>(
                            stream:
                                _firestore
                                    .collection("users")
                                    .doc(uid)
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator(
                                  color: Colors.white,
                                );
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const Text(
                                  "Balance not found",
                                  style: TextStyle(color: Colors.white),
                                );
                              }

                              var data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              int balance = data["balance"] ?? 0;

                              return Text(
                                "₹ $balance",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 🔹 Floating Action Button
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTransactionDialog(context),
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
