import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ghost_money_world/constants/text_helper.dart';

class SettingPage extends StatefulWidget {
  final String title;
  final String text;

  const SettingPage({super.key, required this.title, required this.text});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: customText(
          text: widget.title,
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: customText(
            text: widget.text,
            color: Colors.white,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }
}
