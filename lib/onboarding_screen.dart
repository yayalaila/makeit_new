import 'package:flutter/material.dart';
import 'package:makeit/login_screen.dart';
import 'signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  // Using Icons for the onboarding content
  final List<Map<String, dynamic>> onboardingData = [
    {
      'icon': Icons.lightbulb_outline, // Example icon for the first page
      'title': 'Numerous free trial courses',
      'description': 'Free courses for you to find your way to learning',
    },
    {
      'icon': Icons.speed, // Example icon for the second page
      'title': 'Quick and easy learning',
      'description':
          'Easy and fast learning at any time to help you improve various skills',
    },
    {
      'icon': Icons.calendar_today, // Example icon for the third page
      'title': 'Create your own study plan',
      'description':
          'Study according to the study plan, make study more motivated',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to login directly (implement LoginScreen later)
                  print('Skip button pressed');
                },
                child: Text('Skip', style: TextStyle(color: Colors.grey)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Centering content vertically
                      children: [
                        // Displaying an Icon
                        Icon(
                          onboardingData[index]['icon'],
                          size: 150, // Adjust icon size as needed
                          color: Color(0xFF47E6FB), // Example color for icons
                        ),
                        SizedBox(height: 30),
                        Text(
                          onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          onboardingData[index]['description']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            buildIndicator(),
            SizedBox(height: 30),
            // Buttons only appear on the last onboarding page
            _currentIndex == onboardingData.length - 1
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // *** THIS IS THE NAVIGATION TO SignUpScreen ***
                              print(
                                  'Sign up button pressed. Navigating to SignUpScreen...'); // Debug print for console
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SignUpScreen(), // Navigates to SignUpScreen
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color(0xFF47E6FB), // Cyan-like color
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Sign up',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Navigate to Login Page (implement LoginScreen later)
                              print('Log in button pressed from onboarding');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LoginScreen(), // Navigates to SignUpScreen
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFF47E6FB)),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Log in',
                                style: TextStyle(color: Color(0xFF47E6FB))),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(height: 60), // Space when buttons are not visible
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(onboardingData.length, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 5),
          height: 6,
          width: _currentIndex == index ? 20 : 6,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? Color(0xFF47E6FB)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
