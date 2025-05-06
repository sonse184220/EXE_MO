import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: LoginWrapperMaterial()));
}

