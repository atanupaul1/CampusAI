import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Attendees
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.category ?? 'General',
                          style: const TextStyle(
                            color: Color(0xFFFD5D11),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    event.title,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 18, color: Colors.blueGrey.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location ?? 'Campus',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Date & Time
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 18, color: Colors.blueGrey.shade700),
                      const SizedBox(width: 8),
                      Text(
                        event.startTime != null 
                          ? DateFormat('EEE, MMM d • h:mm a').format(event.startTime!)
                          : 'TBD',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
