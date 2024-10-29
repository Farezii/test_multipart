import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:test_multipart/models/models.dart';
import 'package:test_multipart/providers/imagesProvider.dart';

Future<void> uploadImages(List<ImageObject> imageList) async {
  final uri = Uri.parse('https://your-api-endpoint.com/upload');
  final request = http.MultipartRequest('POST', uri);

  // Limit to 10 images
  final imagesToUpload = imageList.take(10).toList();

  for (var imageObject in imagesToUpload) {
    final imageFile = imageObject.image;
    final stream = http.ByteStream(DelegatingStream(imageFile.openRead()));
    final length = await imageFile.length();

    final multipartFile = http.MultipartFile(
      'images',
      stream,
      length,
      filename: imageFile.path.split('/').last,
    );

    request.files.add(multipartFile);
  }

  final response = await request.send();

  if (response.statusCode == 200) {
    print('Upload successful');
  } else {
    print('Upload failed with status: ${response.statusCode}');
  }
}
