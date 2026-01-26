// lib/ui/widgets/palace_modal.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../app.dart'; // ← 引入 rootNavigatorKey

Future<T?> showPalaceModal<T>({
  String? title,
  String? desc,
  required Widget child,
  bool barrierDismissible = true,
  double maxWidth = 560,
}) {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return Future.value(null);

  return showDialog<T>(
    context: ctx,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (dialogCtx) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(0.08)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ===== Header =====
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title != null)
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textMain,
                                  ),
                                ),
                              if (desc != null && desc.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.3,
                                    color: AppTheme.textSub,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: '关闭',
                          onPressed: () =>
                              Navigator.of(dialogCtx).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,
                    color: Colors.black.withOpacity(0.06),
                  ),

                  // ===== Body =====
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
