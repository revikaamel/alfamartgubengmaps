import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alfamart Gubeng Maps',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFD32F2F),
        fontFamily: 'sans-serif',
      ),
      home: const LoginScreen(),
    );
  }
}