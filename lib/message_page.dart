// lib/screens/message_page.dart
import 'package:flutter/material.dart';
import 'package:makeit/course_page.dart';
import 'package:makeit/profile_page.dart';
import 'package:makeit/search.dart';
import 'package:makeit/student_homepage.dart';
import 'package:makeit/widgets/custom_nav_bar.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentHomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CoursePage()),
        );
        break;
      // Already on CoursePage
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => searchPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MessagePage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProfilePage()), // Replace with your account page
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Page background is white
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar background is white
        elevation: 0, // No shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Colors.black87), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen (Home)
          },
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false, // Title is left-aligned as per image
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0), // Height of the TabBar
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true, // Allow tabs to scroll if many
              labelColor: Colors.black, // Color of selected tab text
              unselectedLabelColor: Colors.grey, // Color of unselected tab text
              indicatorColor: Color(0xFF47E6FB), // Cyan indicator
              indicatorSize:
                  TabBarIndicatorSize.tab, // Indicator covers the tab
              indicatorWeight: 3.0, // Thickness of the indicator
              labelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
              ),
              tabs: [
                Tab(text: 'message'),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('notification'),
                      SizedBox(width: 5),
                      // Orange dot for notification, similar to image
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.orange, // Orange dot
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Message Tab Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildMessageCard(
                  sender: 'Bert Pullman',
                  status: 'Online',
                  time: '04:32 pm',
                  message:
                      'Congratulations on completing the first lesson, keep up the good work!',
                  avatarColor: Colors.lightGreen[100]!, // Example color
                ),
                SizedBox(height: 20),
                _buildMessageCard(
                  sender: 'Daniel Lawson',
                  status: 'Online',
                  time: '04:32 pm',
                  message:
                      'Your course has been updated, you can check the new course in your study course.',
                  avatarColor: Colors.lightBlue[100]!, // Example color
                  hasImagePlaceholder:
                      true, // For the blank image area in the sample
                ),
                SizedBox(height: 20),
                _buildMessageCard(
                  sender: 'Nguyen Shane',
                  status: 'Offline',
                  time: '12:00 am',
                  message:
                      'Congratulations, you have completed your registration! Now start your journey.',
                  avatarColor: Colors.purple[100]!, // Example color
                ),
                SizedBox(height: 20),
                // Add more messages as needed
              ],
            ),
          ),

          // Notification Tab Content (can be similar structure or different)
          Center(
            child: Text('Notifications will appear here!'),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Helper method to build a single message/notification card
  Widget _buildMessageCard({
    required String sender,
    required String status,
    required String time,
    required String message,
    required Color avatarColor,
    bool hasImagePlaceholder = false,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Placeholder
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius:
                      BorderRadius.circular(10), // Slightly rounded square
                ),
                child: Center(
                  child: Icon(Icons.person,
                      color: Colors.grey[600]), // Placeholder icon
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sender,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        color: status == 'Online'
                            ? Colors.green
                            : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasImagePlaceholder) ...[
            SizedBox(height: 10),
            Container(
              height: 100, // Height for the image placeholder
              decoration: BoxDecoration(
                color:
                    Colors.grey[200], // Light grey background for placeholder
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
