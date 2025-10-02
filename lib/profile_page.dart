import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makeit/login_screen.dart';

import 'mentor_home_page.dart' show MentorHomePage;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Lilatu Yaya';
  String email = 'lilatu@example.com';

  void _showEditProfileModal() {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    name = nameController.text;
                    email = emailController.text;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Save Changes'),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _navigateToBecomeMentor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BecomeMentorPage()),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    name,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _showEditProfileModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Courses', '5', Icons.book),
                _buildStatCard('Certificates', '2', Icons.verified),
                _buildStatCard('Active', '3', Icons.school),
              ],
            ),
            SizedBox(height: 30),
            _buildMenuItem(Icons.menu_book, 'My Courses', onTap: () {}),
            _buildMenuItem(Icons.card_membership, 'My Certificates',
                onTap: () {}),
            _buildMenuItem(Icons.settings, 'Settings', onTap: () {}),
            _buildMenuItem(Icons.help_outline, 'Help Center', onTap: () {}),
            _buildMenuItem(Icons.person_add, 'Become a Mentor',
                onTap: _navigateToBecomeMentor),
            _buildMenuItem(Icons.logout, 'Logout',
                color: Colors.red, onTap: _logout),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(15),
          child: Icon(icon, size: 30, color: Colors.blue),
        ),
        SizedBox(height: 8),
        Text(value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title,
      {Color color = Colors.black87, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontSize: 16, color: color)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class BecomeMentorPage extends StatefulWidget {
  const BecomeMentorPage({super.key});

  @override
  _BecomeMentorPageState createState() => _BecomeMentorPageState();
}

class _BecomeMentorPageState extends State<BecomeMentorPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final specialityController = TextEditingController();

  void submitApplication() {
    if (_formKey.currentState!.validate()) {
      // Optionally: save mentor details to Firestore or SharedPreferences

      // Navigate to MentorHomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MentorHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Become a Mentor"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: specialityController,
                decoration: InputDecoration(labelText: 'Speciality'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: submitApplication,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text("Confirm Information"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MentorDashboardPage extends StatelessWidget {
  const MentorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Mentor Home Page"), backgroundColor: Colors.blue),
      body: Center(
        child: Text("Welcome to your dashboard, Mentor!"),
      ),
    );
  }
}
