import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String apiUrl =
      'https://script.google.com/macros/s/AKfycbzD4A2FKHzxO0P_dGtvO_2tBZgDTVr-a-2QJPM_mo7O-yelIYuDGRN4tCVF7amokB53WA/exec';

  static Future<List<dynamic>>
      getPlaces() async {

    final response =
        await http.get(
      Uri.parse(apiUrl),
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );

    } else {

      throw Exception(
        'Failed load data',
      );
    }
  }
}