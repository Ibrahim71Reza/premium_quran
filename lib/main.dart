import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/theme/app_theme.dart';
import 'features/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.premiumquran.audio',
    androidNotificationChannelName: 'Premium Quran Audio',
    androidNotificationOngoing: true,
  );

  await Hive.initFlutter();
  await Hive.openBox<List>('playlistsBox');

  runApp(const ProviderScope(child: PremiumQuranApp()));
}

class PremiumQuranApp extends StatelessWidget {
  const PremiumQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Quran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}