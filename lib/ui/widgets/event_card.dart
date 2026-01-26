import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/game_models.dart';

class EventCard extends StatelessWidget {
  final EventDef event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.eventCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 事件标题
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textMain,
              ),
            ),
            const SizedBox(height: 8),

            // 事件描述
            Text(
              event.description,
              style: TextStyle(
                height: 1.4,
                color: AppTheme.textMain.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
