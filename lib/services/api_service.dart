import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String apiUrl =
      'https://script.google.com/macros/s/AKfycbyDuHtmjoMMl5MB7osrvPKdXlGu0YhbebqF2EbF2JxYg-huo9HEjC-pUFX0rvbBrdRTIw/exec';

  static Future<List<dynamic>> getPlaces() async {

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

  static Future<void> addPlace(
      Map<String, dynamic> place) async {

    final response =
        await http.post(

      Uri.parse(apiUrl),

      headers: {
        "Content-Type":
            "application/json",
      },

      body: jsonEncode({

        "action": "add",

        ...place,
      }),
    );

    print(response.statusCode);
    print(response.body);
  }
}