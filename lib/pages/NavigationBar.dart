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

  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
  fetchNotifications();
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

  Widget _buildNavItem(IconData icon, int index){
    Color iconColor = widget.selectedIndex == index ? Colors.lightBlue : Colors.grey;

    // Count unread notifications
    int unreadCount = notifications.where((notification) => !notification['read']).length;

    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none, // Allow overflow for the badge
        children: [
          Icon(icon, color: iconColor),
          if (index == 2 && unreadCount > 0) // Check if the item is the notification icon and there are unread notifications
            Positioned(
              right: -3, // Adjust the position as needed
              top: -3,
              child: Container(
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Text(
                  '$unreadCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: () async {
        if (index == 3) {
          var docId = await authService.getDocumentIdByUid(_auth.currentUser!.uid);
          Navigator.of(context).pushNamed('/profile', arguments: {'userId': _auth.currentUser!.uid, 'docId': docId});
        } else if (index == 2) {
          _showNotifications(context);
        } else {
          widget.onItemSelected(index);
        }
      },
    );
  }


  void _showNotifications(BuildContext context) {
    markAllNotificationsAsRead();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Notifications"),
          content: ConstrainedBox(
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
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        color: index % 2 == 0 ? Colors.white : Colors.grey[100],
                        child: Row(
                          children: [
                            Stack(children: [
                              const Icon(Icons.notifications,
                                  color: Colors.black54),
                              if (!notifications[index]['read'])
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    width: 5.0,
                                    height: 5.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ]),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Text(
                                notifications[index]['text'],
                                style: const TextStyle(color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  notifications = notifications.map((notification) {
                    return {
                      ...notification,
                      'read': true
                    };
                  }).toList();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future fetchNotifications() async {
    try {
      var userDoc = await firestore.collection('users').doc(_auth.currentUser?.uid);
      var notifications = await userDoc.collection('notifications').get();
      List<Map<String, dynamic>> fetchedNotifications = [];
      for (var doc in notifications.docs) {
        fetchedNotifications.add({'text': doc.data()['text'], 'read': doc.data()['read']});
      }
      if (mounted) {
        setState(() {
          this.notifications = fetchedNotifications;
        });
      }
    } catch(e) {

    }
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
