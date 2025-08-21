import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_x/Authentication/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _numberController = TextEditingController();

  User? get user => _auth.currentUser; // ✅ single source of truth

  // Save balance to Firestore
  Future<void> saveBalance() async {
    if (_numberController.text.isEmpty) return;

    final uid = user?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No user logged in")));
      return;
    }

    int number = int.parse(_numberController.text);

    // ✅ Increment instead of replacing
    await _firestore.collection("users").doc(uid).set({
      "balance": FieldValue.increment(number),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Added ₹$number to balance!")));
    _numberController.clear();
  }

  // Logout
  void logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SigninScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'Anonymous User';
    final email = user?.email ?? 'No email';
    final uid = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile picture and info
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
            ),
            const SizedBox(height: 12),
            Text(
              displayName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Balance input
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: "Enter Balance",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: saveBalance,
              child: const Text("Save Balance"),
            ),
            const SizedBox(height: 20),

            // Show balance from Firestore
            if (uid != null)
              StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection("users").doc(uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text("No balance saved yet.");
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final balance = (data["balance"] ?? 0) + 0;

                  return Text(
                    "Your Balance: ₹$balance",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),

            const Divider(height: 32),

            // Dark Mode
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
              secondary: const Icon(Icons.brightness_6),
            ),

            // Notifications
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              secondary: const Icon(Icons.notifications),
            ),

            const Divider(height: 32),

            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                logout();
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                  );
                },
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
