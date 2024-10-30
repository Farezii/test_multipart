import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:test_multipart/models/models.dart';
import 'dart:io';

const hostname = 'http://172.28.188.65';
const port = ':8080';

List<List<ImageObject>> chunkListIntoTens(List<ImageObject> imageObjectList) {
  final List<List<ImageObject>> separatedList = [];
  final int length = imageObjectList.length;
  final int fullChunks = length ~/ 10;
  final int remainingChunk = length % 10;

  for (var i = 0; i < fullChunks; i++) {
    separatedList.add(imageObjectList.sublist(i * 10, (i + 1) * 10));
  }

  if (remainingChunk > 0) {
    separatedList.add(imageObjectList.sublist(fullChunks * 10));
  }

  return separatedList;
}

Future<void> uploadChunkImages(List<ImageObject> imageList) async {
  final uri = Uri.parse('$hostname$port/upload/');
  print('URI: $uri');
  final request = http.MultipartRequest('POST', uri);
  Map<String, List<String>> data = {'ids': [], 'timestamps': []};

  // Limit to 10 images
  final imageObjectsToUpload = imageList.take(10).toList();

  for (var imageObject in imageObjectsToUpload) {
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
    data['ids']!.add(imageObject.id.toString());
    data['timestamps']!.add(imageObject.timestamp.toIso8601String());
  }

  request.fields['ids'] = data['ids']!.join(',');
  request.fields['timestamps'] = data['timestamps']!.join(',');

  final response = await request.send();

  if (response.statusCode == 201) {
    print('Upload successful');
  } else {
    print('Upload failed with status: ${response.statusCode}');
    final responseBody = await response.stream.bytesToString();
    print('Response body: $responseBody');
  }
}

Future<void> uploadAllImages(List<ImageObject> imageList) async {
  final List<List<ImageObject>> separatedList = chunkListIntoTens(imageList);

  for (var chunk in separatedList) {
    await uploadChunkImages(chunk);
  }
}
