import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MySecureStorage {
  final _storage = const FlutterSecureStorage();
  static const _keybookname = 'bookname';
  static const _keybookdescription = 'bookdescription';
  static const _keybookgenre = 'bookgenre';
  static const _keybookprice = 'bookprice';

  Future saveBookDraft(
    String bookname,
    String bookdescription,
    String bookgenre,
    String bookprice,
  ) async {
    await _storage.write(key: _keybookname, value: bookname);
    await _storage.write(key: _keybookdescription, value: bookdescription);
    await _storage.write(key: _keybookgenre, value: bookgenre);
    await _storage.write(key: _keybookprice, value: bookprice);
  }

  Future<String?> getBookname() async {
    return await _storage.read(key: _keybookname);
  }

  Future<String?> getBookdescription() async {
    return await _storage.read(key: _keybookdescription);
  }

  Future<String?> getBookgenre() async {
    return await _storage.read(key: _keybookgenre);
  }

  Future<String?> getBookprice() async {
    return await _storage.read(key: _keybookprice);
  }

  Future deleteAll() async {
    await _storage.deleteAll();
  }
}
