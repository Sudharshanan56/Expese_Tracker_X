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
//         child: Column(
//           children: [
//             Stack(
//               children: [
//                 Container(
//                   height: 400,
//                   width: double.infinity,
//                   color: Colors.black,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(18.0),
//                             child: CircleAvatar(
//                               radius: 30,
//                               backgroundColor: Colors.white,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 10),
//                             child: Text(
//                               'Hello, ' + (userName ?? 'User'),
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           Spacer(),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => GoalPage(),
//                                   ),
//                                 );
//                               },
//                               child: Icon(
//                                 Icons.grade_rounded,
//                                 color: Colors.white,
//                                 size: 30,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 300),
//                   child: Container(
//                     height: 350,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(30),
//                         topRight: Radius.circular(30),
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 60),
//                       child: ListView.builder(
//                         itemCount: 5, // Number of items in the list
//                         itemBuilder: (context, index) {
//                           return ListTile(
//                             leading: Icon(Icons.list),
//                             title: Text('Item ${index + 1}'),
//                             subtitle: Text('This is item number ${index + 1}'),
//                             trailing: Icon(Icons.arrow_forward),
//                             onTap: () {
//                               print('Tapped on item ${index + 1}');
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),

//                 Padding(
//                   padding: const EdgeInsets.only(top: 170, left: 20),
//                   child: Container(
//                     height: 200,
//                     width: 375,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30),
//                       color: Colors.green,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Center(
//         child: StreamBuilder<DocumentSnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection("users")
//               .doc(uid)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const CircularProgressIndicator();
//             }
//             if (!snapshot.hasData || !snapshot.data!.exists) {
//               return const Text("Balance not found");
//             }

//             var data = snapshot.data!.data() as Map<String, dynamic>;
//             int balance = data["balance"] ?? 0;

//             return Text(
//               "₹ $balance",
//               style: const TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//               ),
//             );
//           },
//         ),
//       ),
//     );

//   }
// }

//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // fallback to FirebaseAuth info
      setState(() {
        userName = user.displayName ?? "No Name";
        userEmail = user.email ?? "No Email";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? uid = user?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("No user logged in")));
    }

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              // 🔹 Top Black Header,
              Positioned(
                left: 20,
                child: Container(
                  height: 200,
                  width: 375,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.green,
                  ),
                  child: Center(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream:
                          FirebaseFirestore.instance
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
                            color: Colors.white, // ✅ White text on green
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Container(
                height: 400,
                width: double.infinity,
                color: Colors.black,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
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
              ),

              // 🔹 Balance Card

              // 🔹 White Bottom List
              Padding(
                padding: const EdgeInsets.only(top: 300),
                child: Container(
                  height: 350,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: ListView.builder(
                      itemCount: 5, // Number of items in the list
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.list),
                          title: Text('Item ${index + 1}'),
                          subtitle: Text('This is item number ${index + 1}'),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            print('Tapped on item ${index + 1}');
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
