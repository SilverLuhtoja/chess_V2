import 'package:chess_v2/src/App.dart';
import 'package:chess_v2/src/services/uuid_service.dart';
import 'package:chess_v2/src/values/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  await getUUID(); //wait until uuid is created
  runApp(ProviderScope(child: App()));
}

