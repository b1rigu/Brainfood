import 'package:animations/animations.dart';
import 'package:brainfood/models/news_model.dart';
import 'package:brainfood/widgets/appbar.dart';
import 'package:brainfood/widgets/search_widget.dart';
import 'package:brainfood/widgets/superellipse_shape.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<String> newsGenres = [
    'All',
    'World',
    'Animal',
    'Education',
    'Sport',
    'Games',
    'Plant',
    'Vacation',
    'Fashion',
    'Food',
    'Film',
    'Tech',
    'Music',
  ];

  List<IconData> newsGenreIcons = [
    IconlyLight.activity,
    IconlyLight.discovery,
    Icons.donut_large_outlined,
    IconlyLight.work,
    IconlyLight.paper,
    IconlyLight.game,
    Icons.terrain_outlined,
    IconlyLight.star,
    IconlyLight.bag_2,
    Icons.food_bank_outlined,
    Icons.movie_outlined,
    Icons.laptop_outlined,
    Icons.my_library_music_outlined,
  ];

  List<NewsModel> news = [
    NewsModel(
      uid: '',
      userimageUrl:
          'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fkeenthemes.com%2Fpreview%2Fmetronic%2Ftheme%2Fassets%2Fpages%2Fmedia%2Fprofile%2Fprofile_user.jpg',
      username: 'Michael P',
      imageUrl:
          'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.thesouthafrican.com%2Fwp-content%2Fuploads%2F2021%2F01%2F4ef49e1b-latest-sports-news-scaled.jpg.optimal.jpg',
      genre: 'SPORT',
      newsTime: FieldValue.serverTimestamp(),
      newsId: '',
      title: 'How the football player here would be pro player in the future',
      text: '',
    ),
    NewsModel(
      uid: '',
      userimageUrl:
          'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fkeenthemes.com%2Fpreview%2Fmetronic%2Ftheme%2Fassets%2Fpages%2Fmedia%2Fprofile%2Fprofile_user.jpg',
      username: 'Michael P',
      imageUrl:
          'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.reuters.com%2Fresizer%2FuwFbdLtIH44GfNNlUeJ6DfitwmE%3D%2F1200x628%2Fsmart%2Ffilters%3Aquality(80)%2Fcloudfront-us-east-2.images.arcpublishing.com%2Freuters%2FRZ4TQC44HZL27NFU6PLQHRZRYY.jpg',
      genre: 'WORLD',
      newsTime: FieldValue.serverTimestamp(),
      newsId: '',
      title: 'Canadian diplomats barred from tycoon\'s trial in China',
      text: '',
    ),
    NewsModel(
      uid: '',
      userimageUrl:
          'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fkeenthemes.com%2Fpreview%2Fmetronic%2Ftheme%2Fassets%2Fpages%2Fmedia%2Fprofile%2Fprofile_user.jpg',
      username: 'Michael P',
      imageUrl:
          'https://scontent.fuln1-2.fna.fbcdn.net/v/t1.15752-9/289976394_5289140607845091_4124615373230889753_n.png?_nc_cat=104&ccb=1-7&_nc_sid=ae9488&_nc_ohc=uGh002YI2rcAX-ltHt7&_nc_oc=AQlycFMobfSBBVBkVpITllVlSjejfZbd5oVsHUdvdGFuICXnEPwhjfJT626axboQ7do&tn=NBLdnSGcw99i_eIu&_nc_ht=scontent.fuln1-2.fna&oh=03_AVLizshJhoob4GASTnvxONvfyVpiHiemByJmcZ51VHHnXw&oe=62E7B4EE',
      genre: 'TECH',
      newsTime: FieldValue.serverTimestamp(),
      newsId: '',
      title: 'Brainfood changed their logo and it was surprising',
      text: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: appBar(context, true),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 45,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: genre(newsGenres[index], newsGenreIcons[index]),
                      );
                    },
                    itemCount: 13,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: height * 0.4,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: bigNewsWidget(width, height, news[index]),
                      );
                    },
                    itemCount: news.length,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 6.0, right: 32.0),
                      child: Text(
                        'Recommendation',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'See more',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22.0, vertical: 6.0),
                child: SizedBox(
                  height: height * 0.1,
                  child: smallNewsWidget(width, height, news[2]),
                ),
              ),
            ],
          ),
          //search widget
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: OpenContainer(
                closedShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
                transitionType: ContainerTransitionType.fadeThrough,
                closedBuilder: (_, openContainer) {
                  return searchWidget(openContainer, 'Search for article...');
                },
                openBuilder: (_, __) {
                  return const Scaffold();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget genre(String text, IconData icon) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon == IconlyLight.activity
                ? const SizedBox.shrink()
                : Icon(icon, size: 18),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bigNewsWidget(width, height, NewsModel news) {
    return Container(
      height: double.infinity,
      width: width * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(238, 238, 238, 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height * 0.21,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
              child: Text(
                news.genre,
                style: const TextStyle(
                  color: Colors.grey,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 32.0),
              child: Text(
                news.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 17.0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 8.0),
              child: Row(
                children: [
                  ClipPath(
                    clipper: CustomClipPath(),
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: CachedNetworkImage(
                        imageUrl: news.userimageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    news.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    ' • 3 hour ago',
                    style: TextStyle(
                        color: Color.fromRGBO(180, 180, 180, 1),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget smallNewsWidget(width, height, NewsModel news) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(238, 238, 238, 1),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(imageUrl: news.imageUrl),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        news.genre,
                        style: const TextStyle(
                          color: Colors.grey,
                          letterSpacing: 1.5,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '3 hour ago',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 22.0),
                    child: Text(
                      news.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
