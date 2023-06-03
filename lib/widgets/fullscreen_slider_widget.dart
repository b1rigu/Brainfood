import 'package:brainfood/widgets/custom_pageview_scroll_physics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

class FullscreenSlider extends StatefulWidget {
  final snap;
  final docs;
  final index;
  final bool isChat;
  const FullscreenSlider(
      {Key? key,
      this.snap,
      required this.isChat,
      this.docs,
      required this.index})
      : super(key: key);

  @override
  State<FullscreenSlider> createState() => _FullscreenSliderState();
}

class _FullscreenSliderState extends State<FullscreenSlider> {
  List<dynamic> images = [];
  int _current = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    _current = widget.index;
    if (widget.isChat) {
      for (var doc in widget.docs) {
        print('gg');
        List<dynamic> image = doc.data()['imageUrl'];
        if (image.isNotEmpty) {
          images.addAll(image);
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
                scrollPhysics: const CustomPageViewScrollPhysics(),
                initialPage: widget.index,
                height: height * 0.8,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
            items: widget.isChat
                ? images
                    .map(
                      (item) => Center(
                        child: ZoomOverlay(
                          minScale: 1.0,
                          maxScale: 2.0,
                          twoTouchOnly: true,
                          child: CachedNetworkImage(
                            fit: BoxFit.contain,
                            height: height * 0.8,
                            imageUrl: item,
                          ),
                        ),
                      ),
                    )
                    .toList()
                : widget.snap['imageUrl']
                    .map<Widget>(
                      (item) => Center(
                        child: ZoomOverlay(
                          minScale: 1.0,
                          maxScale: 2.0,
                          twoTouchOnly: true,
                          child: CachedNetworkImage(
                            fit: BoxFit.contain,
                            height: height * 0.8,
                            imageUrl: item,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.isChat
                ? images.asMap().entries.map((entry) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    );
                  }).toList()
                : widget.snap['imageUrl'].asMap().entries.map<Widget>((entry) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }
}
