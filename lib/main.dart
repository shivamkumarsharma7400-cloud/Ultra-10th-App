import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Pure Black & White system bar overlay (matches website light/ink aesthetic)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFFFFFF),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const Ultra10thApp());
}

class Ultra10thApp extends StatelessWidget {
  const Ultra10thApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultra 10th - MCQ Practice',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        colorScheme: const ColorScheme.light(
          brightness: Brightness.light,
          surface: Color(0xFFFFFFFF),
          background: Color(0xFFF7F7F7),
          primary: Color(0xFF111111),
          onPrimary: Color(0xFFFFFFFF),
          secondary: Color(0xFF222222),
          onSecondary: Color(0xFFFFFFFF),
          outline: Color(0xFFDEDEDE),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF111111),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
