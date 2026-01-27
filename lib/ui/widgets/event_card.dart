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
      color: AppTheme.eventCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
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
