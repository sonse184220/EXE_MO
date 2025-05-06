import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signInWithGoogle() async {
  final googleSignIn = GoogleSignIn();

  // Optional: sign out first to force account selection
  await googleSignIn.signOut();

  // Trigger Google Sign-In flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  if (googleUser == null) {
    throw Exception('Sign in aborted');
  }

  // Get the authentication details
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Sign in to Firebase with the Google credential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
