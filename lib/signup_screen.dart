// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:makeit/student_homepage.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscureText = true;
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ensure white background as in image
      body: SafeArea(
        child: SingleChildScrollView(
          // Added SingleChildScrollView to prevent overflow on smaller screens/keyboards
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50), // Spacing from top
              Text(
                'Sign Up As A Student',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Enter your details below & free sign up',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40), // Space between description and first input

              Text(
                'Your Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors
                      .grey[100], // Light grey background for the input field
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Cooper_Kristin@gmail.com',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none, // Remove default border
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    enabledBorder: OutlineInputBorder(
                      // Define border when enabled
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // Define border when focused
                      borderSide: BorderSide(
                          color: Color(0xFF47E6FB)), // Cyan border when focused
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              SizedBox(height: 25),

              Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors
                      .grey[100], // Light grey background for the input field
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: '••••••••••••',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none, // Remove default border
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    enabledBorder: OutlineInputBorder(
                      // Define border when enabled
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // Define border when focused
                      borderSide: BorderSide(
                          color: Color(0xFF47E6FB)), // Cyan border when focused
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  // TODO: Implement account creation logic
                  print('Create account button pressed');
                  print('Agreed to terms: $_agreedToTerms');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StudentHomePage(), // Navigates to StudentHomePage
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF47E6FB), // Cyan-like color
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize:
                      Size(double.infinity, 0), // Make button full width
                ),
                child: Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),

              Row(
                children: [
                  SizedBox(
                    width: 24, // Standard size for a checkbox
                    height: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _agreedToTerms = newValue ?? false;
                        });
                      },
                      activeColor:
                          Color(0xFF47E6FB), // Cyan color for checked state
                      side: BorderSide(
                          color:
                              Colors.grey), // Grey border for unchecked state
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    // Use Expanded to prevent overflow for long text
                    child: Text.rich(
                      TextSpan(
                        text:
                            'By creating an account you have to agree with our ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                'them & condication.', // Typo from image "condication"
                            style: TextStyle(
                              color:
                                  Color(0xFF47E6FB), // Cyan color for this part
                              fontWeight: FontWeight
                                  .bold, // Make it bold if it's a link
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // This pops the current screen off the navigation stack
                      // and returns to the previous screen (which would be OnboardingScreen)
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF47E6FB), // Cyan-like color
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
