import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const p = 'assets/images/avatars/opening/avatar_balanced_01.png';
  try {
    await rootBundle.load(p);
    // ignore: avoid_print
    print('✅ asset OK: $p');
  } catch (e) {
    // ignore: avoid_print
    print('❌ asset FAIL: $p\n$e');
  }

  runApp(const ProviderScope(child: App()));
}