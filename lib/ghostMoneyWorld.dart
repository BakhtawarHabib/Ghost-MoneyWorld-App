import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/screens/splash/splash_screen.dart';

class GhostMoneyWorld extends StatefulWidget {
  const GhostMoneyWorld({Key? key}) : super(key: key);

  @override
  State<GhostMoneyWorld> createState() => _GhostMoneyWorldState();
}

class _GhostMoneyWorldState extends State<GhostMoneyWorld> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ghost Money World',
          theme: ThemeData(
            fontFamily: 'Nunito',
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
