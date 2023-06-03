import 'package:animations/animations.dart';
import 'package:brainfood/screens/book_detail_screen.dart';
import 'package:brainfood/widgets/book_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({Key? key}) : super(key: key);

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _searchByName = false;
  bool _isLoading = false;
  List<dynamic> books = [];
  List<dynamic> tempbookSearchResults = [];
  List<dynamic> bookSearchResults = [];
  List<String> bookGenres = [
    'Clear',
    'БАЙГАЛИЙН ШИНЖЛЭЛ',
    'БИЗНЕС, ЭДИЙН ЗАСАГ',
    'БЭЛГИЙН НОМ',
    'ГАЗРЫН ЗУРАГ',
    'КОМИК, МАНГА',
    'МАТЕМАТИК, ШИНЖЛЭХ УХААН',
    'НАМТАР, ДУРСАМЖ',
    'НАРИЙН МЭРГЭЖИЛ, ҮЙЛДВЭРЛЭЛ',
    'НИЙГМИЙН ШИНЖЛЭХ УХААН',
    'НЭВТЭРХИЙ ТОЛЬ, ГАРЫН АВЛАГА',
    'ӨӨРТӨӨ ТУСЛАХ',
    'СПОРТ',
    'СУРАХ БИЧИГ',
    'ТҮҮХ',
    'УРАН ЗОХИОЛ',
    'УРЛАГ, СОЁЛ, ГЭРЭЛ ЗУРАГ',
    'ХОББИ, ЧӨЛӨӨТ ЦАГ, ХООЛ',
    'ХӨДӨӨ АЖ АХУЙ',
    'ХУУЛЬ, ЭРХ ЗҮЙ',
    'ХҮҮХДИЙН НОМ',
    'ХЭЛ, ТОЛЬ БИЧИГ',
    'ШАШИН',
    'ЭРҮҮЛ МЭНД, ГЭР БҮЛ',
    'БУСАД',
  ];
  String chosenGenre = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void getData() async {
    FirebaseFirestore fstore = FirebaseFirestore.instance;
    books.clear();
    QuerySnapshot<Map<String, dynamic>> allBooks =
        await fstore.collection('books').get();
    for (var book in allBooks.docs) {
      var myBook = book.data();
      books.add(myBook);
    }
    setState(() {});
  }

  void updateList(String value) {
    bookSearchResults.clear();
    tempbookSearchResults.clear();
    setState(() => _isLoading = true);
    if (value == '') {
      //empty
    } else {
      if (_searchByName) {
        for (var book in books) {
          if (book['bookname'].toLowerCase().contains(value.toLowerCase())) {
            tempbookSearchResults.add(book);
          }
        }
      } else {
        for (var book in books) {
          for (var totrade in book['booksToTrade']) {
            if (totrade.toLowerCase().contains(value.toLowerCase())) {
              tempbookSearchResults.add(book);
              break;
            }
          }
        }
      }
      if (chosenGenre.isNotEmpty && chosenGenre != 'Clear') {
        for (var result in tempbookSearchResults) {
          if (result['genre'] == chosenGenre) {
            bookSearchResults.add(result);
          }
        }
      } else {
        bookSearchResults.addAll(tempbookSearchResults);
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            searchWidget(),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _searchByName = true;
                        updateList(_searchController.text.trim());
                      }),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: _searchByName
                              ? Colors.deepPurple[300]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(),
                        ),
                        child: Center(
                          child: Text(
                            'By name',
                            style: TextStyle(
                              color:
                                  _searchByName ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _searchByName = false;
                        updateList(_searchController.text.trim());
                      }),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: _searchByName
                              ? Colors.white
                              : Colors.deepPurple[300],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(),
                        ),
                        child: Center(
                          child: Text(
                            'By to trade',
                            style: TextStyle(
                              color:
                                  _searchByName ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    openChoices();
                  },
                  child: const SizedBox(
                    height: 60,
                    width: 60,
                    child: Icon(
                      IconlyLight.filter,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: OpenContainer(
                      closedShape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(12.0))),
                      transitionType: ContainerTransitionType.fadeThrough,
                      closedBuilder: (_, openContainer) {
                        return BookContainer(
                          ontap: openContainer,
                          snap: bookSearchResults[index],
                        );
                      },
                      openBuilder: (_, __) {
                        return BookDetailScreen(
                          snap: bookSearchResults[index],
                        );
                      },
                    ),
                  );
                },
                itemCount: bookSearchResults.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          updateList(value);
        },
        autofocus: true,
        textAlignVertical: TextAlignVertical.top,
        controller: _searchController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            IconlyLight.search,
            color: Colors.black87,
            size: 28,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search books...',
          suffixIcon: IconButton(
            splashRadius: 18.0,
            onPressed: () {
              if (_searchController.text.isEmpty) {
                Navigator.of(context).pop();
              } else {
                _searchController.clear();
                FocusScope.of(context).unfocus();
                updateList('');
              }
            },
            icon: const Icon(
              Icons.close,
              color: Color.fromRGBO(149, 117, 205, 1),
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }

  void openChoices() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            primary: false,
            itemBuilder: (context, index) {
              if (chosenGenre == bookGenres[index]) {
                return ListTile(
                  dense: true,
                  selected: true,
                  selectedColor: Colors.white,
                  selectedTileColor: Colors.deepPurple[300],
                  leading: const Icon(IconlyLight.bookmark),
                  onTap: () {
                    setState(() {
                      chosenGenre = bookGenres[index];
                    });
                    updateList(_searchController.text.trim());
                    Navigator.of(context).pop();
                  },
                  title: Text(bookGenres[index]),
                );
              }
              return ListTile(
                dense: true,
                leading: const Icon(IconlyLight.bookmark),
                onTap: () {
                  setState(() {
                    chosenGenre = bookGenres[index];
                  });
                  updateList(_searchController.text.trim());
                  Navigator.of(context).pop();
                },
                title: Text(bookGenres[index]),
              );
            },
            itemCount: bookGenres.length,
          ),
        );
      },
    );
  }
}
