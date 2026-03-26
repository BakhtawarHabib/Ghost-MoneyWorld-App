import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:svg_flutter/svg.dart';

class Customtextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPassword;
  final String? prefixSvgIcon;

  const Customtextfield({
    super.key,
    required this.hintText,
    required this.controller,
    this.errorText,
    this.validator,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.isPassword = false,
    this.prefixSvgIcon,
  });

  @override
  State<Customtextfield> createState() => _CustomtextfieldState();
}

class _CustomtextfieldState extends State<Customtextfield> {
  bool _obscure = true;

  OutlineInputBorder _border() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(11.r),
    borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.isPassword ? _obscure : false,
      style: const TextStyle(color: Colors.white),

      validator: (value) {
        if (value == null || value.isEmpty) {
          return widget.errorText;
        }
        if (widget.validator != null) {
          return widget.validator!(value);
        }
        return null;
      },

      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        counterText: "",

        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(),

        prefixIcon:
            widget.prefixSvgIcon != null
                ? Padding(
                  padding: const EdgeInsets.all(14),
                  child: SvgPicture.asset(
                    widget.prefixSvgIcon!,
                    height: 20.h,
                    width: 20.w,
                    color: Colors.white,
                  ),
                )
                : null,

        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    _obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() => _obscure = !_obscure);
                  },
                )
                : null,
      ),
    );
  }
}
