// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ghost_money_world/constants/app_colors.dart';
// import 'package:ghost_money_world/constants/shared_ref.dart';
// import 'package:ghost_money_world/screens/authScreens/loginScreen.dart';

// class ProfileController extends GetxController {
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;
//   final _storage = FirebaseStorage.instance;

//   bool isLoading = false;
//   bool isDeleting = false;

//   String? email;
//   String? name;

//   String? phone;
//   String? photoUrl;

//   Future<void> fetchProfile() async {
//     try {
//       isLoading = true;
//       update();

//       final user = _auth.currentUser;
//       if (user == null) {
//         Get.snackbar(
//           'Error',
//           'User not logged in',
//           backgroundColor: AppColors.primaryColor,
//         );
//         isLoading = false;
//         update();
//         return;
//       }

//       final uid = user.uid;

//       final doc = await _firestore.collection('users').doc(uid).get();

//       if (!doc.exists) {
//         isLoading = false;
//         update();
        
//         Get.snackbar(
//           'Error',
//           'Profile not found',
//           backgroundColor: AppColors.primaryColor,
//         );
        
//         // Clear data and logout
//         await removeUserData();
//         await removeFirebaseUserID();
        
//         // Get.offAll(() => LoginScreen());
//         return;
//       }

//       final data = doc.data() ?? {};
//       email = data['email'] ?? '';
//       name = data['name'] ?? '';

//       phone = data['phone'] ?? '';
//       photoUrl = data['photoUrl'] ?? '';
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to load profile',
//         backgroundColor: AppColors.primaryColor,
//       );
//     } finally {
//       isLoading = false;
//       update();
//     }
//   }

//   Future<void> deleteAccount() async {
//     try {
//       isDeleting = true;
//       update();

//       final user = _auth.currentUser;
//       if (user == null) {
//         Get.snackbar(
//           'Error',
//           'User not logged in',
//           backgroundColor: AppColors.primaryColor,
//         );
//         isDeleting = false;
//         update();
//         return;
//       }

//       final uid = user.uid;

//       // 1. Delete all videos created by the user
//       try {
//         final videosSnapshot =
//             await _firestore
//                 .collection('videos')
//                 .where('userId', isEqualTo: uid)
//                 .get();

//         for (var videoDoc in videosSnapshot.docs) {
//           final videoData = videoDoc.data();

//           // Delete video file from Storage
//           if (videoData['video'] != null &&
//               videoData['video'].toString().isNotEmpty) {
//             try {
//               final videoRef = _storage.refFromURL(videoData['video']);
//               await videoRef.delete();
//             } catch (e) {
//               print('Error deleting video file: $e');
//             }
//           }

//           // Delete thumbnail from Storage
//           if (videoData['thumbnail'] != null &&
//               videoData['thumbnail'].toString().isNotEmpty) {
//             try {
//               final thumbnailRef = _storage.refFromURL(videoData['thumbnail']);
//               await thumbnailRef.delete();
//             } catch (e) {
//               print('Error deleting thumbnail: $e');
//             }
//           }

//           // Delete video document
//           await videoDoc.reference.delete();
//         }
//       } catch (e) {
//         print('Error deleting videos: $e');
//       }

//       // 2. Delete all categories created by the user
//       try {
//         final categoriesSnapshot =
//             await _firestore
//                 .collection('categories')
//                 .where('userId', isEqualTo: uid)
//                 .get();

//         for (var categoryDoc in categoriesSnapshot.docs) {
//           await categoryDoc.reference.delete();
//         }
//       } catch (e) {
//         print('Error deleting categories: $e');
//       }

//       // 3. Delete user profile image from Storage
//       if (photoUrl != null && photoUrl!.isNotEmpty) {
//         try {
//           final profileImageRef = _storage.refFromURL(photoUrl!);
//           await profileImageRef.delete();
//         } catch (e) {
//           print('Error deleting profile image: $e');
//         }
//       }

//       // 4. Delete user document from Firestore
//       await _firestore.collection('users').doc(uid).delete();

//       // 5. Delete user from Firebase Authentication
//       await user.delete();

//       // 6. Clear local storage
//       await removeFirebaseUserID();

//       // 7. Show success message and redirect to login
//       Get.snackbar(
//         'Success',
//         'Your account has been deleted successfully',
//         backgroundColor: Colors.green,
//       );

//       // Navigate to login screen
//       // Get.offAll(() => LoginScreen());
//     } on FirebaseAuthException catch (e) {
//       Get.snackbar(
//         'Error',
//         e.message ?? 'Failed to delete account',
//         backgroundColor: AppColors.primaryColor,
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to delete account: ${e.toString()}',
//         backgroundColor: AppColors.primaryColor,
//       );
//     } finally {
//       isDeleting = false;
//       update();
//     }
//   }
// }
