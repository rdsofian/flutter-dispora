import 'package:dispora/pages/dashboard.page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SIDORA',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
          //   bodyText1: GoogleFonts.montserrat(textStyle: textTheme.bodyText1),
          // ),
        ),
        home: const DashboardPage());
  }
}
