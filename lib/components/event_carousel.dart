import 'package:flutter/material.dart';
import 'package:ticke_it/components/event_widget.dart';

class EventCarousel extends StatelessWidget {
  final List events;

  EventCarousel({required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventWidget(event: events[index]);
        },
      ),
    );
  }
}