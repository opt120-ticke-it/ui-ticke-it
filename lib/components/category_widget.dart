import 'package:flutter/material.dart';
import 'package:ticke_it/components/event_carousel.dart';

class CategoryWidget extends StatelessWidget {
  final Map category;

  CategoryWidget({required this.category});

  @override
  Widget build(BuildContext context) {
    final events = category['events'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            category['name'],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        EventCarousel(events: events),
      ],
    );
  }
}