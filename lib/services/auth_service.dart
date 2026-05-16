import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(name);
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'phone': '',
        'bio': '',
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return credential;
  }

  Future<UserCredential> signInAsGuest() {
    return _auth.signInAnonymously();
  }

  User? get currentUser => _auth.currentUser;

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _auth.currentUser?.getIdToken(forceRefresh);
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
    String? bio,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name);
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      await user.updatePhotoURL(photoUrl.trim());
    }

    final payload = <String, dynamic>{
      'uid': user.uid,
      'name': name,
      'email': user.email ?? '',
      'phone': (phone ?? '').trim(),
      'bio': (bio ?? '').trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      payload['photoUrl'] = photoUrl.trim();
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(payload, SetOptions(merge: true));
  }

  Future<String> uploadProfilePhoto({
    required File file,
    required String userId,
  }) async {
    final ref = _storage
        .ref()
        .child('users/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'no-user', message: 'Not signed in');
    }
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'no-email',
        message: 'Email sign-in required to change password',
      );
    }
    final cred = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> deleteCurrentUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'no-user', message: 'Not signed in');
    }

    final uid = user.uid;

    // Best-effort app data cleanup before deleting FirebaseAuth user.
    await _deleteUserOwnedDocs(collection: 'videos', userId: uid);
    await _deleteUserOwnedDocs(collection: 'categories', userId: uid);
    await _deleteUserOwnedDocs(collection: 'liveStreams', userId: uid);
    await _firestore.collection('users').doc(uid).delete();
    await _storage.ref().child('users/$uid').listAll().then((result) async {
      for (final fileRef in result.items) {
        await fileRef.delete();
      }
    }).catchError((_) {
      // Folder may not exist yet.
    });

    await user.delete();
  }

  Future<void> _deleteUserOwnedDocs({
    required String collection,
    required String userId,
  }) async {
    const ownerFieldCandidates = ['uid', 'userId', 'createdBy', 'ownerId'];

    for (final field in ownerFieldCandidates) {
      final snapshot =
          await _firestore
              .collection(collection)
              .where(field, isEqualTo: userId)
              .get()
              .catchError((_) => null);
      if (snapshot == null || snapshot.docs.isEmpty) continue;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> signOut() => _auth.signOut();
}
