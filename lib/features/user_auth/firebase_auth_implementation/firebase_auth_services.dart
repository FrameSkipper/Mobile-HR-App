import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<FirebaseAuthService> authService = ValueNotifier(FirebaseAuthService());

class FirebaseAuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
})async {
    return await firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
}) async{
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    await userCredential.user!.updateDisplayName("$firstName $lastName");
    await userCredential.user!.reload();

    return userCredential;
  }

  Future<void> signOut() async{
    await firebaseAuth.signOut();
  }
  
  Future<void> resetPassword({
    required String email,
})async{
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({
    required String username,
  })async{
    await currentUser!.updateDisplayName(username);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
})async{
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  })async{
    AuthCredential credential =
      EmailAuthProvider.credential(email: email, password: currentPassword);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}