import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users/buisenisse_logic/assistant_provider/assistant_provider.dart';
import 'package:users/buisenisse_logic/maps_provider/maps_provider.dart';
import 'package:users/presentation/screens/splach_screen/splach_screen.dart';

import 'buisenisse_logic/auth_provider/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(

      providers: [

        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<AssistantsService>(create: (_) => AssistantsService()),
        ChangeNotifierProvider<MapsProvider>(create: (_) => MapsProvider()),
      ],
    
    child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplachScreen(),
    );
  }
}
