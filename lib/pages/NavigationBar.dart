import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/pages/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  AuthService authService = AuthService();

  final List<IconData> navIcons = [
    Icons.home_outlined,
    Icons.calendar_month_outlined,
    Icons.notifications_active_outlined,
    Icons.person_2_outlined,
  ];

  Stream<List<Map<String, dynamic>>>? notificationsStream;

  @override
  void initState() {
    super.initState();
    notificationsStream = streamNotifications();
  }


  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navIcons.asMap().entries.map((entry) {
          int idx = entry.key;
          IconData icon = entry.value;
          return _buildNavItem(icon, idx);
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    Color iconColor = widget.selectedIndex == index ? Colors.lightBlue : Colors.grey;

    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none, // Allow overflow for badge
        children: [
          Icon(icon, color: iconColor), // Main icon
          if (index == 2) // Assuming notifications icon is at index 2
            Positioned(
              right: -6,
              top: -3,
              child: StreamBuilder<int>(
                stream: streamUnreadNotificationCount(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data! > 0) {
                    return Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '${snapshot.data}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return SizedBox(); // No badge if no unread notifications
                  }
                },
              ),
            ),
        ],
      ),
      onPressed: () {
        if(index == 2) {
          _showNotifications(context);
          widget.onItemSelected(index);
        } else if (index == 3) {
          Navigator.pushNamed(context, '/profile', arguments: {'userId': _auth.currentUser?.uid});
        }
        widget.onItemSelected(index);

      },
    );
  }


  String formatDuration(DateTime notificationTime) {
    Duration difference = DateTime.now().difference(notificationTime);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Notifications"),
          content: StreamBuilder<List<Map<String, dynamic>>>(
            stream: notificationsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Text("No notifications yet.");
              }
              var notifications = snapshot.data!;
              return ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List<Widget>.generate(
                        notifications.length,
                            (index) {
                          return buildNotificationItem(notifications[index]);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
                markAllNotificationsAsRead();
              },
            ),
          ],
        );
      },
    ).then((value) => {
      markAllNotificationsAsRead()
    });
  }

  Widget buildNotificationItem(Map<String, dynamic> notification) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: notification['read'] ? Colors.grey[100] : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications, color: Colors.black54),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['text'],
                  style: TextStyle(color: Colors.black87),
                  softWrap: true,
                ),
                Text(
                  formatDuration(notification['timestamp']),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Stream<List<Map<String, dynamic>>> streamNotifications() {
    return firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'text': doc.data()['text'] as String,
          'read': doc.data()['read'] as bool,
          'timestamp': (doc.data()['timestamp'] as Timestamp).toDate(),
        };
      }).toList();
    });
  }

  Stream<int> streamUnreadNotificationCount() {
    return firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('notifications')
        .where('read', isEqualTo: false) // Only get unread notifications
        .snapshots()
        .map((snapshot) => snapshot.docs.length); // Map to the count of unread notifications
  }


  Future<void> markAllNotificationsAsRead() async {
    var collectionRef = firestore.collection('users').doc(_auth.currentUser?.uid).collection('notifications');
    try {
      var querySnapshot = await collectionRef.get();
      var batch = firestore.batch();
      for (var doc in querySnapshot.docs) {
        var docRef = doc.reference;
        batch.update(docRef, {'read': true});
      }
      await batch.commit();
      print('All notifications have been marked as read.');
    } catch (e) {
      print('Error updating documents: $e');
    }
  }

}
