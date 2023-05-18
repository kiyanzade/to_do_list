import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/data/repo/repository.dart';
import 'package:to_do_list/data/source/hive_task_source.dart';
import 'package:to_do_list/screens/home/home.dart';

import 'data/data.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>('tasks');
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xff794CFF),
      statusBarBrightness: Brightness.light));
  runApp(ChangeNotifierProvider(
      create: (context) => Repository<Task>(HiveTaskDataSource(Hive.box('tasks'))),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final primaryTextColor = const Color(0xff1D2830);
    final secondaryTextColor = const Color(0xffAFBED0);
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.

          textTheme: GoogleFonts.poppinsTextTheme(
            const TextTheme(
              headline6: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: secondaryTextColor),
            iconColor: secondaryTextColor,
            border: InputBorder.none,
          ),
          colorScheme: ColorScheme.light(
            primary: const Color(0xff794CFF),
            primaryVariant: const Color(0xff5C0AFF),
            background: const Color(0xffF3F5F8),
            onSurface: primaryTextColor,
            onBackground: primaryTextColor,
            secondary: const Color(0xff794CFF),
            onSecondary: Colors.white,
            onTertiary: secondaryTextColor,
          ),
        ),
        home: const HomeScreen());
  }
}
