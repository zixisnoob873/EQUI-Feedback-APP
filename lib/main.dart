import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF080809),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final supabase = SupabaseService();
  await supabase.initialize();

  runApp(
    const ProviderScope(
      child: EquilibriumGamingZone(),
    ),
  );
}
