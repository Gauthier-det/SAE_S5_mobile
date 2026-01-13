import 'package:http/http.dart' as http;

class RaceApiSources {
  final String baseUrl;
  final http.Client client;

  RaceApiSources({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();
}
