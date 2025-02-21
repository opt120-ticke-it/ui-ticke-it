import 'package:flutter/material.dart';
import 'package:ticke_it/components/event_widget.dart';

class EventCarousel extends StatefulWidget {
  final List events;
  final double? height; // Parâmetro opcional para a altura

  EventCarousel({
    required this.events,
    this.height,
  });

  @override
  _EventCarouselState createState() => _EventCarouselState();
}

class _EventCarouselState extends State<EventCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: _currentPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.animateToPage(
        widget.events.length - 1,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollRight() {
    if (_currentPage < widget.events.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calcula a altura baseada em uma proporção 4:3 para a imagem + espaço para o texto
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85; // 85% da largura da tela
    final imageHeight = (cardWidth * 3) / 4; // Mantém proporção 4:3
    final totalHeight =
        imageHeight + 140; // Altura da imagem + espaço para texto e padding

    return Container(
      height: widget.height ?? totalHeight,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.events.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: EventWidget(event: widget.events[index]),
              );
            },
          ),

          // Botões de navegação
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavigationButton(
                  Icons.arrow_back_ios_new_rounded,
                  _scrollLeft,
                  EdgeInsets.only(left: 5),
                ),
                _buildNavigationButton(
                  Icons.arrow_forward_ios_rounded,
                  _scrollRight,
                  EdgeInsets.only(right: 5),
                ),
              ],
            ),
          ),

          // Indicadores de página
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.events.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    IconData icon,
    VoidCallback onPressed,
    EdgeInsets padding,
  ) {
    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, size: 24),
          onPressed: onPressed,
          color: Theme.of(context).primaryColor,
          splashRadius: 24,
        ),
      ),
    );
  }
}
