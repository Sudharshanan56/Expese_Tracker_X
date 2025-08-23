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
  DateTime? selectedDate; // ✅ new field
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // ✅ Fetch transactions by month or day
  Stream<QuerySnapshot> getTransactions() {
    if (selectedDate != null) {
      // 🔹 If user selected a date → filter that day
      final startOfDay = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      // 🔹 Otherwise → show full month
      final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final endOfMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
        1,
      );

      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where('timestamp', isLessThan: Timestamp.fromDate(endOfMonth))
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedDate != null
              ? "Transactions - ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
              : "Transactions - ${selectedMonth.month}/${selectedMonth.year}",
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
                helpText: "Select Date",
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked; // ✅ store the selected day
                  selectedMonth = picked; // keep month aligned
                });
              }
            },
          ),
          if (selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: "Clear Date Filter",
              onPressed: () {
                setState(
                  () => selectedDate = null,
                ); // ✅ reset back to month view
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                selectedDate != null
                    ? "No transactions found for this date."
                    : "No transactions found for this month.",
              ),
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
