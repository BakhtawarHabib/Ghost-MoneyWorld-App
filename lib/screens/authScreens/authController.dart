// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ghost_money_world/constants/app_colors.dart';
// import 'package:ghost_money_world/constants/shared_ref.dart';
// import 'package:ghost_money_world/screens/bottomBar/customBottomBarScreen.dart';
// import 'package:ghost_money_world/widgets/showLoaderDialog.dart';
// import 'package:image_picker/image_picker.dart';

// class AuthController extends GetxController {
//   final registerEmailController = TextEditingController();
//   final registerPasswordController = TextEditingController();
//   final emailController = TextEditingController();
//   final phoneController = TextEditingController();
//   final passwordController = TextEditingController();
//   final nameController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;
//   final ImagePicker _picker = ImagePicker();

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String? profileImageUrl;
//   File? profileImageFile;

//   void _setLoading(bool value) {
//     _isLoading = value;
//     update();
//   }

//   void showImageSourceSheet() {
//     Get.bottomSheet(
//       Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: const BoxDecoration(
//           color: Colors.black,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//         ),
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt, color: Colors.white),
//               title: const Text(
//                 'Camera',
//                 style: TextStyle(color: Colors.white),
//               ),
//               onTap: () => _pickImage(ImageSource.camera),
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library, color: Colors.white),
//               title: const Text(
//                 'Gallery',
//                 style: TextStyle(color: Colors.white),
//               ),
//               onTap: () => _pickImage(ImageSource.gallery),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: source,
//         imageQuality: 75,
//       );

//       if (pickedFile != null) {
//         profileImageFile = File(pickedFile.path);
//         update();
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to pick image',
//         backgroundColor: AppColors.primaryColor,
//       );
//     } finally {
//       if (Get.isBottomSheetOpen ?? false) {
//         Get.back();
//       }
//     }
//   }

//   Future<String?> _uploadProfileImage(String uid) async {
//     if (profileImageFile == null) return null;

//     try {
//       final ref = FirebaseStorage.instance
//           .ref()
//           .child('user_profile_images')
//           .child('$uid.jpg');

//       await ref.putFile(profileImageFile!);
//       final url = await ref.getDownloadURL();
//       return url;
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to upload profile image',
//         backgroundColor: AppColors.primaryColor,
//       );
//       return null;
//     }
//   }

//   Future<void> signUp() async {
//     final email = registerEmailController.text.trim();
//     final phone = phoneController.text.trim();
//     final password = registerPasswordController.text.trim();
//     final confirmPassword = confirmPasswordController.text.trim();
//     final name = nameController.text.trim();

//     if (email.isEmpty ||
//         phone.isEmpty ||
//         password.isEmpty ||
//         confirmPassword.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'All fields are required',
//         backgroundColor: AppColors.primaryColor,
//       );
//       return;
//     }

//     if (password != confirmPassword) {
//       Get.snackbar(
//         'Error',
//         'Passwords do not match',
//         backgroundColor: AppColors.primaryColor,
//       );
//       return;
//     }

//     _setLoading(true);

//     try {
//       // Always store phone with +1 (United States) country code
//       String normalizedPhone = phone.replaceAll(RegExp(r'\s+'), '');
//       if (!normalizedPhone.startsWith('+')) {
//         // If user typed only digits, prefix with +1
//         if (!normalizedPhone.startsWith('1')) {
//           normalizedPhone = '1$normalizedPhone';
//         }
//         normalizedPhone = '+$normalizedPhone';
//       }

//       UserCredential cred = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final uid = cred.user?.uid;
//       if (uid == null) {
//         throw Exception('User UID is null');
//       }

//       final imageUrl = await _uploadProfileImage(uid);
//       profileImageUrl = imageUrl;

//       await _firestore.collection('users').doc(uid).set({
//         'uid': uid,
//         'email': email,
//         'name': name,
//         'phone': normalizedPhone,
//         'photoUrl': imageUrl ?? '',
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       await saveFirebaseUserID(uid.toString());

//       Get.snackbar(
//         'Success',
//         'Account created successfully',
//         backgroundColor: AppColors.primaryColor,
//       );
//       Get.offAll(() => CustomBottomBarScreen());
//     } on FirebaseAuthException catch (e) {
//       Get.snackbar(
//         'Auth Error',
//         e.message ?? 'Something went wrong',
//         backgroundColor: AppColors.primaryColor,
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         e.toString(),
//         backgroundColor: AppColors.primaryColor,
//       );
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> signIn(BuildContext context) async {
//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Email and Password are required',
//         backgroundColor: AppColors.primaryColor,
//       );
//       return;
//     }

//     // Show loading dialog
//     showLoaderDialog(context);
//     _setLoading(true);

//     try {
//       UserCredential cred = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final uid = cred.user?.uid;
//       if (uid == null) {
//         throw Exception('User UID is null');
//       }
//       await saveFirebaseUserID(uid.toString());

//       hideLoaderDialog();
//       _setLoading(false);

//       Get.offAll(() => CustomBottomBarScreen());
//     } on FirebaseAuthException catch (e) {
//       hideLoaderDialog();
//       _setLoading(false);

//       await Future.delayed(const Duration(milliseconds: 150));

//       Get.snackbar(
//         'Auth Error',
//         e.message ?? 'Something went wrong',
//         backgroundColor: AppColors.primaryColor,
//         duration: const Duration(seconds: 3),
//       );
//     } catch (e) {
//       hideLoaderDialog();
//       _setLoading(false);

//       await Future.delayed(const Duration(milliseconds: 150));

//       Get.snackbar(
//         'Error',
//         e.toString(),
//         backgroundColor: AppColors.primaryColor,
//         duration: const Duration(seconds: 3),
//       );
//     }
//   }

//   @override
//   void onClose() {
//     emailController.dispose();
//     phoneController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.onClose();
//   }
// }
