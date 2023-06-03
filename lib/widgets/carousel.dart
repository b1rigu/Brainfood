import 'package:brainfood/widgets/custom_pageview_scroll_physics.dart';
import 'package:brainfood/widgets/imageViewWidget.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';

class CustomCarousel extends StatefulWidget {
  final images;
  final aspectRatio;
  final double width;
  const CustomCarousel(
      {Key? key,
      required this.images,
      required this.aspectRatio,
      required this.width})
      : super(key: key);

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  double height = 0.0;
  int _current = 0;
  late PageController _pageController;
  int _touchCount = 0;

  @override
  void initState() {
    super.initState();
    getHeight();
    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);
  }

  void getHeight() {
    height = (widget.width - 16) / widget.aspectRatio;
  }

  void _incrementEnter(PointerEvent details) {
    setState(() {
      _touchCount++;
    });
  }

  void _incrementExit(PointerEvent details) {
    setState(() {
      _touchCount--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 5.0,
        maxHeight: 1000.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 3,
            child: Listener(
              onPointerDown: _incrementEnter,
              onPointerUp: _incrementExit,
              onPointerCancel: _incrementExit,
              child: ExpandablePageView.builder(
                physics: _touchCount > 1
                    ? const NeverScrollableScrollPhysics()
                    : const CustomPageViewScrollPhysics(),
                animateFirstPage: true,
                estimatedPageSize: height,
                controller: _pageController,
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  return imageSlider(widget.images[index]);
                },
                onPageChanged: (index) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.images.asMap().entries.map<Widget>((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget imageSlider(String imageUrl) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, widget) {
        return Center(
          child: widget,
        );
      },
      child: ImageViewWidget(
        imageUrl: imageUrl,
        aspectRatio: widget.aspectRatio,
        width: widget.width,
      ),
    );
  }
}
