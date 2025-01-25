import 'package:aifer_education_machine_test/route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp( MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
  }

  @override
  void dispose() {

  }




  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.noTransition,
      initialRoute: '/',
      unknownRoute: GetPage(name: '/error404', page: () =>  Container()),
      getPages: routes,
    );
  }
}




