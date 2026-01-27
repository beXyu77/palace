import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PalaceModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool dismissible = true,
    double maxWidth = 520,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: 'PalaceModal',
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, anim1, anim2) {
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Material(
                color: Colors.transparent,
                child: _ModalFrame(
                  dismissible: dismissible,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, _, child) {
        final curve = Curves.easeOutCubic.transform(anim.value);
        return Opacity(
          opacity: anim.value,
          child: Transform.scale(
            scale: 0.96 + curve * 0.04,
            child: child,
          ),
        );
      },
    );
  }
}

class _ModalFrame extends StatelessWidget {
  final Widget child;
  final bool dismissible;

  const _ModalFrame({
    required this.child,
    required this.dismissible,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                blurRadius: 30,
                offset: const Offset(0, 18),
                color: Colors.black.withOpacity(0.25),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: child,
        ),

        // 右上角关闭按钮
        Positioned(
          top: 6,
          right: 6,
          child: IconButton(
            icon: const Icon(Icons.close_rounded),
            splashRadius: 18,
            tooltip: '关闭',
            onPressed: dismissible ? () => Navigator.of(context).pop() : null,
          ),
        ),
      ],
    );
  }
}
