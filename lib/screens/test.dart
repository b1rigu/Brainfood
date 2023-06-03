import 'package:brainfood/utils/firestore_methods.dart';
import 'package:brainfood/utils/rsa.dart';
import 'package:brainfood/widgets/my_text_field.dart';
import 'package:brainfood/widgets/text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/pointycastle.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  //Future to hold our KeyPair
  late Future<crypto.AsymmetricKeyPair> futureKeyPair;

  //to store the KeyPair once we get data from our future
  late crypto.AsymmetricKeyPair keyPair;

  String texting = '';
  String decryptedtexting = '';

  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
      getKeyPair() {
    var helper = RsaKeyHelper();
    return helper.computeRSAKeyPair(helper.getSecureRandom());
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  void initState() {
    super.initState();
    getNewKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyTextField(
                keyboardType: TextInputType.text,
                labelText: 'to encrypt',
                controller: _textEditingController,
                onpressX: () {},
                useFormatter: false,
              ),
              MyTextButton(
                text: 'encrypt and send',
                onPressed: () {
                  encryptAndSend(_textEditingController.text);
                },
                boxcolor: Colors.white,
                textcolor: Colors.black,
              ),
              StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('test').snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemBuilder: (context, index) {
                      final encryptedText =
                          snapshot.data!.docs[index].data()['text'];
                      final String decrypted = decryptAndShow(encryptedText);
                      return Container(
                        height: 30,
                        color: Colors.amber,
                        child: Text('decrypted: $decrypted'),
                      );
                    },
                    itemCount: snapshot.data!.docs.length,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void encryptAndSend(String text) async {
    final String encryptedString =
        encrypt(text, keyPair.publicKey as RSAPublicKey);
    await FirestoreMethods().sendEncryptedMessage(text: encryptedString);
  }

  String decryptAndShow(String encryptedText) {
    final String decryptedString =
        decrypt(encryptedText, keyPair.privateKey as RSAPrivateKey);
    return decryptedString;
  }

  void getNewKeys() async {
    futureKeyPair = getKeyPair();
    keyPair = await futureKeyPair;
  }
}
