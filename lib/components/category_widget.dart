import 'package:flutter/material.dart';
import 'package:ticke_it/components/event_carousel.dart';

class CategoryWidget extends StatelessWidget {
  final Map category;

  const CategoryWidget({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final events = category['events'] ?? [];
    final categoryName = category['name'] ?? '';
    final description = category['description'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título da categoria
                Text(
                  categoryName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),

                // Descrição da categoria (se houver)
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                    ),
                  ),
              ],
            ),
          ),

          // Mensagem quando não há eventos
          if (events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum evento disponível nesta categoria',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            EventCarousel(
              events: events,
              height: 320,
            ),

          // Espaçador após o carousel
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
