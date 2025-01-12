import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_search_app/pages/home_page.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
    MobileAds.instance.initialize();
    runApp(const MyApp());
}
class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.dark
                ),
                useMaterial3: true,
            ),
            home: const HomePage(),
        );
    }
}
