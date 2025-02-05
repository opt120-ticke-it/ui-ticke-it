import 'package:flutter/material.dart';
import 'package:ticke_it/components/event_widget.dart';

class EventCarousel extends StatefulWidget {
  final List events;

  EventCarousel({required this.events});

  @override
  _EventCarouselState createState() => _EventCarouselState();
}

class _EventCarouselState extends State<EventCarousel> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    if (_scrollController.offset <= 0) {
      // Se estiver no início, rola para o final
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    } else {
      _scrollController.animateTo(
        _scrollController.offset - 200,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollRight() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
      // Se estiver no final, volta para o primeiro item
      _scrollController.jumpTo(0);
    } else {
      _scrollController.animateTo(
        _scrollController.offset + 200,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: _scrollLeft,
            ),
            Expanded(
              child: SizedBox(
                height: 250,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.events.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: EventWidget(event: widget.events[index]),
                    );
                  },
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: _scrollRight,
            ),
          ],
        ),
      ],
    );
  }
}