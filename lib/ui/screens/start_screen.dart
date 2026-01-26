import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('紫宸宫 · MVP')),
      body: Center(
        child: SizedBox(
          width: 360,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('第一版：选秀入宫 · 日回合 · 月末考评', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/create'),
              child: const Text('新开局：选秀入宫'),
            ),
          ]),
        ),
      ),
    );
  }
}
