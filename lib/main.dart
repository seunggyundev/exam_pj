import 'package:devjang_cs/firebase_options.dart';
import 'package:devjang_cs/pages/home_page.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  ///for firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (BuildContext context) => PageProvider()), // page는 모든 페이지에서 다루기 때문에 최상단에
          ],
          child: const MyApp())
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
