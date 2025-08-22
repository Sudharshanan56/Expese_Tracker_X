// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class MonthlyTransactionsScreen extends StatefulWidget {
//   const MonthlyTransactionsScreen({Key? key}) : super(key: key);

//   @override
//   State<MonthlyTransactionsScreen> createState() => _MonthlyTransactionsScreenState();
// }

// class _MonthlyTransactionsScreenState extends State<MonthlyTransactionsScreen> {
//   DateTime selectedMonth = DateTime.now();
//   final String uid = FirebaseAuth.instance.currentUser!.uid; // 👈 current userId

//   Stream<QuerySnapshot> getTransactionsByMonth(DateTime selectedMonth) {
//     final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
//     final endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

//     return FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid) // 👈 navigate to current user
//         .collection('transactions')
//         .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
//         .where('createdAt', isLessThan: Timestamp.fromDate(endOfMonth))
//         .snapshots();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Transactions - ${selectedMonth.month}/${selectedMonth.year}"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.calendar_month),
//             onPressed: () async {
//               final picked = await showDatePicker(
//                 context: context,
//                 initialDate: selectedMonth,
//                 firstDate: DateTime(2020),
//                 lastDate: DateTime(2035),
//                 helpText: "Select Month",
//               );
//               if (picked != null) {
//                 setState(() => selectedMonth = picked);
//               }
//             },
//           )
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: getTransactionsByMonth(selectedMonth),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No transactions found for this month."));
//           }

//           final docs = snapshot.data!.docs;

//           double total = 0;
//           for (var doc in docs) {
//             total += (doc['balance'] as num).toDouble();
//           }

//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Text(
//                   "Total Balance: ₹${total.toStringAsFixed(2)}",
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     final data = docs[index].data() as Map<String, dynamic>;
//                     return Card(
//                       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       child: ListTile(
//                         leading: const Icon(Icons.payment),
//                         title: Text(data['name'] ?? "No Name"),
//                         subtitle: Text(data['email'] ?? "No Email"),
//                         trailing: Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text("₹${data['balance']}"),
//                             Text(
//                               (data['createdAt'] as Timestamp).toDate().toString(),
//                               style: const TextStyle(fontSize: 12),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonthlyTransactionsScreen extends StatefulWidget {
  const MonthlyTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyTransactionsScreen> createState() =>
      _MonthlyTransactionsScreenState();
}

class _MonthlyTransactionsScreenState extends State<MonthlyTransactionsScreen> {
  DateTime selectedMonth = DateTime.now();
  final String uid =
      FirebaseAuth.instance.currentUser!.uid; // current logged-in user

  // ✅ Fetch transactions by month
  Stream<QuerySnapshot> getTransactionsByMonth(DateTime selectedMonth) {
    final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfMonth))
        .orderBy('timestamp', descending: true) // optional: latest first
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Transactions - ${selectedMonth.month}/${selectedMonth.year}",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                helpText: "Select Month",
              );
              if (picked != null) {
                setState(() => selectedMonth = picked);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getTransactionsByMonth(selectedMonth),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No transactions found for this month."),
            );
          }

          final docs = snapshot.data!.docs;

          double total = 0;
          for (var doc in docs) {
            total += (doc['amount'] as num).toDouble();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Total Spent: ₹${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.payment),
                        title: Text(data['category'] ?? "No Category"),
                        subtitle: Text("Amount: ₹${data['amount']}"),
                        trailing: Text(
                          (data['timestamp'] as Timestamp)
                              .toDate()
                              .toString()
                              .split(" ")[0],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
