import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:makeit/login_screen.dart';
import 'package:makeit/mentor_home_page.dart';
import 'package:makeit/upload_course_page.dart';
import 'package:makeit/main.dart';

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

  // Replace navigation to direct mentor page with application form
  void _navigateToBecomeMentor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MentorApplicationPage()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsPage()),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
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
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
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
            _buildMenuItem(Icons.menu_book, 'My Courses', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MentorHomePage()),
              );
            }),
            _buildMenuItem(Icons.card_membership, 'My Certificates',
                onTap: () {}),
            _buildMenuItem(Icons.settings, 'Settings', onTap: _navigateToSettings),
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushNotifications = true;
  bool emailUpdates = true;
  bool courseRecommendations = true;
  bool autoplayPreviews = false;
  bool downloadOverWifiOnly = true;
  bool dataSaver = false;
  bool showCertificates = true;
  TimeOfDay reminderTime = TimeOfDay(hour: 19, minute: 0);
  String language = 'English';

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );
    if (picked != null && mounted) {
      setState(() => reminderTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeControllerScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Appearance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          SwitchListTile(
            title: Text('Dark Theme'),
            subtitle: Text('Reduce eye strain in low light'),
            value: themeController.isDark,
            onChanged: (v) => setState(() => themeController.setDark(v)),
          ),
          Divider(height: 32),
          Text('Learning Preferences',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          SwitchListTile(
            title: Text('Course Recommendations'),
            subtitle: Text('Personalized suggestions based on activity'),
            value: courseRecommendations,
            onChanged: (v) => setState(() => courseRecommendations = v),
          ),
          SwitchListTile(
            title: Text('Autoplay Course Previews'),
            subtitle: Text('Auto-play short previews in course lists'),
            value: autoplayPreviews,
            onChanged: (v) => setState(() => autoplayPreviews = v),
          ),
          ListTile(
            title: Text('Learning Reminder Time'),
            subtitle: Text(
              '${reminderTime.format(context)}',
            ),
            trailing: Icon(Icons.access_time),
            onTap: _pickReminderTime,
          ),
          Divider(height: 32),
          Text('Downloads & Data',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          SwitchListTile(
            title: Text('Wi-Fi Only Downloads'),
            subtitle: Text('Prevent mobile data usage for downloads'),
            value: downloadOverWifiOnly,
            onChanged: (v) => setState(() => downloadOverWifiOnly = v),
          ),
          SwitchListTile(
            title: Text('Data Saver'),
            subtitle: Text('Lower video quality to save data'),
            value: dataSaver,
            onChanged: (v) => setState(() => dataSaver = v),
          ),
          Divider(height: 32),
          Text('Notifications',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          SwitchListTile(
            title: Text('Push Notifications'),
            subtitle: Text('Class updates and reminders'),
            value: pushNotifications,
            onChanged: (v) => setState(() => pushNotifications = v),
          ),
          SwitchListTile(
            title: Text('Email Updates'),
            subtitle: Text('Announcements and progress summaries'),
            value: emailUpdates,
            onChanged: (v) => setState(() => emailUpdates = v),
          ),
          Divider(height: 32),
          Text('Account & Display',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          SwitchListTile(
            title: Text('Show Certificates Publicly'),
            subtitle: Text('Display earned certificates on your profile'),
            value: showCertificates,
            onChanged: (v) => setState(() => showCertificates = v),
          ),
          ListTile(
            title: Text('Language'),
            subtitle: Text(language),
            trailing: DropdownButton<String>(
              value: language,
              underline: SizedBox.shrink(),
              items: [
                'English',
                'French',
                'Spanish',
                'Arabic',
              ].map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => language = v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Replaced the previous BecomeMentorPage with a mentor application form
class MentorApplicationPage extends StatefulWidget {
  const MentorApplicationPage({super.key});

  @override
  _MentorApplicationPageState createState() => _MentorApplicationPageState();
}

class _MentorApplicationPageState extends State<MentorApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specialityController = TextEditingController();
  final TextEditingController motivationController = TextEditingController();
  final TextEditingController whyBestController = TextEditingController();
  final TextEditingController backgroundController = TextEditingController();

  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please sign in to apply')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _db.collection('mentor_applications').add({
        'userId': user.uid,
        'email': user.email,
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'speciality': specialityController.text.trim(),
        'motivation': motivationController.text.trim(),
        'whyBest': whyBestController.text.trim(),
        'background': backgroundController.text.trim(),
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Application submitted. We will review it soon.')),
        );
        // Navigate to course upload page so mentor can create a course
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UploadCoursePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    specialityController.dispose();
    motivationController.dispose();
    whyBestController.dispose();
    backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentor Application'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Apply to become a mentor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: specialityController,
                decoration:
                    InputDecoration(labelText: 'Speciality / Course Area'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: motivationController,
                decoration: InputDecoration(
                    labelText: 'Why do you want to teach this course?'),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: whyBestController,
                decoration: InputDecoration(
                    labelText: 'Why are you the best to teach it?'),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: backgroundController,
                decoration:
                    InputDecoration(labelText: 'Background / Experience'),
                maxLines: 4,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : submitApplication,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('Submit Application',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
