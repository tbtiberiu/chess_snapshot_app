import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';

class ChessPositionDetection {
  final String baseUrl = 'http://192.168.80.81:8080';

  Future<String> analyseImage(String imagePath) async {
    final File imageFile = File(imagePath);

    if (!imageFile.existsSync()) {
      throw Exception('Image file does not exist');
    }

    final Uint8List imageBytes = await File(imagePath).readAsBytes();
    final Image? image = decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final Image resizedImage = resizeImage(image, maxDimension: 700);
    final Uint8List resizedImageBytes = encodePng(resizedImage);

    var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/api/get_chess_position'));
    request.files.add(http.MultipartFile.fromBytes('image', resizedImageBytes,
        filename: 'snapshot.png'));

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

  Image resizeImage(Image image, {int maxDimension = 700}) {
    int width = image.width;
    int height = image.height;
    int minDimension = width < height ? width : height;

    if (minDimension > maxDimension) {
      if (width > height) {
        width = maxDimension;
        height = (maxDimension * image.height / image.width).round();
      } else {
        height = maxDimension;
        width = (maxDimension * image.width / image.height).round();
      }
      image = copyResize(image, width: width, height: height);
    }

    return image;
  }
}
