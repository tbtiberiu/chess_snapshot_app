import 'dart:convert';
import 'package:http/http.dart' as http;

class ChessPositionDetection {
  Future<String> analyseImage(String imagePath) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.82.107:8080/api/get_chess_position'));
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();
    if (response.statusCode == 200) {
      var jsonResponse = await response.stream.bytesToString();
      var jsonMap = json.decode(jsonResponse);
      var fenValue = jsonMap['fen'];
      return fenValue;
    } else {
      throw Exception('Failed to upload image');
    }
  }
}
