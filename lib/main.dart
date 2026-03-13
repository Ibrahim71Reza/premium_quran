import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PremiumQuranApp()));
}

class PremiumQuranApp extends StatelessWidget {
  const PremiumQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Quran',
      debugShowCheckedModeBanner: false, // Hides the red debug banner
      theme: AppTheme.darkTheme,         // Applies our luxury colors
      home: const Scaffold(
        body: Center(
          child: Text(
            'Bismillah.\nFoundation Ready.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}