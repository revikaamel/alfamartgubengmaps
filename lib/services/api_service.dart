import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String apiUrl =
      'https://script.google.com/macros/s/AKfycbyL1L2bECCq2oYH7bGBvaiPHl-qNGoHTQvQDVzk-D763yRc5mlwcoLRteENZUDattr7/exec';

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