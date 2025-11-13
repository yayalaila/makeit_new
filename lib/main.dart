import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import your pages (use your filenames)
import 'package:makeit/login_screen.dart';
import 'package:makeit/signup_screen.dart';
import 'package:makeit/student_homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MakeIt',
      home: AuthGate(), // <-- replaces the "Firebase is linked!" widget
      routes: {
        '/login': (_) => LoginScreen(),
        '/signup': (_) => SignUpScreen(),
        '/home': (_) => StudentHomePage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // user signed in
        if (snapshot.hasData) {
          return StudentHomePage();
        }

        // not signed in
        return LoginScreen();
      },
    );
  }
}
