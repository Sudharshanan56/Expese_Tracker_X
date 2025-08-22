// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:expense_tracker_x/Goal/goal.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   static final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String? userName;
//   String? userEmail;

//   @override
//   void initState() {
//     super.initState();
//     fetchUserDetails();
//   }

//   Future<void> fetchUserDetails() async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     final doc = await _firestore.collection('users').doc(user.uid).get();

//     if (doc.exists) {
//       setState(() {
//         userName = doc['name'];
//         userEmail = doc['email'];
//       });
//     } else {
//       // fallback to FirebaseAuth info
//       setState(() {
//         userName = user.displayName ?? "No Name";
//         userEmail = user.email ?? "No Email";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final User? user = FirebaseAuth.instance.currentUser;
//     final String? uid = user?.uid;

//     if (uid == null) {
//       return const Scaffold(body: Center(child: Text("No user logged in")));
//     }

//     return Scaffold(
//       body: Container(
//         color: Colors.white,
//         child: Column(
//           // mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               children: [
//                 //  Black Header
//                 Container(
//                   height: 400,
//                   width: double.infinity,
//                   color: Colors.black,
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Row(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(18.0),
//                           child: CircleAvatar(
//                             radius: 30,
//                             backgroundColor: Colors.white,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 10),
//                           child: Text(
//                             'Hello, ${userName ?? 'User'}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         const Spacer(),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => GoalPage(),
//                                 ),
//                               );
//                             },
//                             child: const Icon(
//                               Icons.grade_rounded,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // 🔹 White Bottom List
//                 Padding(
//                   padding: EdgeInsets.only(top: 300),
//                   child: Container(
//                     height: 600,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(30),
//                         topRight: Radius.circular(30),
//                       ),
//                       // border: Border.all(color: Colors.black),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 60),
//                       child: ListView.builder(
//                         itemCount: 5, // Number of items in the list
//                         itemBuilder: (context, index) {
//                           return ListTile(
//                             leading: const Icon(Icons.list),
//                             title: Text('Item ${index + 1}'),
//                             subtitle: Text('This is item number ${index + 1}'),
//                             trailing: const Icon(Icons.arrow_forward),
//                             onTap: () {
//                               print('Tapped on item ${index + 1}');
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx
//                 Positioned(
//                   top: 150,
//                   left: 20,
//                   right: 20,
//                   child: Container(
//                     height: 180,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30),
//                       color: Colors.green,
//                     ),
//                     child: Center(
//                       child: StreamBuilder<DocumentSnapshot>(
//                         stream:
//                             FirebaseFirestore.instance
//                                 .collection("users")
//                                 .doc(uid)
//                                 .snapshots(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const CircularProgressIndicator(
//                               color: Colors.white,
//                             );
//                           }
//                           if (!snapshot.hasData || !snapshot.data!.exists) {
//                             return const Text(
//                               "Balance not found",
//                               style: TextStyle(color: Colors.white),
//                             );
//                           }

//                           var data =
//                               snapshot.data!.data() as Map<String, dynamic>;
//                           int balance = data["balance"] ?? 0;

//                           return Text(
//                             "₹ $balance",
//                             style: const TextStyle(
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_x/Calender/calender.dart';
import 'package:expense_tracker_x/Goal/goal.dart';
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

  Future<void> addTransaction(String category, int amount) async {
    // 1️⃣ Save transaction in "transactions"
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("transactions")
        .add({
          "category": category,
          "amount": amount,
          "timestamp": FieldValue.serverTimestamp(),
        });

    // 2️⃣ Update budget if exists
    DocumentReference budgetRef = _firestore
        .collection("users")
        .doc(uid)
        .collection("budgets")
        .doc(category);

    DocumentSnapshot budgetSnap = await budgetRef.get();

    if (budgetSnap.exists) {
      await budgetRef.update({"expense": FieldValue.increment(amount)});
    }
    DocumentReference userRef = _firestore.collection("users").doc(uid);
    await userRef.update({
      "balance": FieldValue.increment(-amount), // 👈 subtract amount
    });
  }

  Future<void> _showAddTransactionDialog(BuildContext context) async {
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
                items:
                    categories.map((cat) {
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

                await addTransaction(finalCategory, amount);

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
          leading: Icon(Icons.menu, color: Colors.white),
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
              // ListTile(
              //   title: const Text('Business'),
              //   selected: _selectedIndex == 1,
              //   onTap: () {
              //     _onItemTapped(1);
              //     Navigator.pop(context);
              //   },
              // ),
              // ListTile(
              //   title: const Text('School'),
              //   selected: _selectedIndex == 2,
              //   onTap: () {
              //     _onItemTapped(2);
              //     Navigator.pop(context);
              //   },
              // ),
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
                                var data =
                                    transactions[index].data()
                                        as Map<String, dynamic>;
                                String category =
                                    data["category"]?.toString() ?? "Other";
                                int amount = data["amount"] ?? 0;

                                return ListTile(
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
                                  trailing: Text(
                                    "₹ $amount",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
