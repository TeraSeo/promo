import 'package:dio/dio.dart';

class TranslatorServer {

  TranslatorServer._privateConstructor();

  static final TranslatorServer _instance = TranslatorServer._privateConstructor();

  factory TranslatorServer() {
    return _instance;
  }

  final url = "http://translator-server-promo-app-env.eba-nqejxiwr.us-east-1.elasticbeanstalk.com/translator";

  Future<void> translate(String description, String targetLang) async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get(url + "?description=$description&targetLang=$targetLang");

    print(response.data.toString());
  }

}