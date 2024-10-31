import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_multipart/models/models.dart';
import 'dart:io';

const hostname = 'http://172.28.188.65';
const port = ':8080';
final uri = Uri.parse('$hostname$port/upload/');

List<List<ImageObject>> chunkListIntoTens(List<ImageObject> imageObjectList) {
  final List<List<ImageObject>> separatedList = [];
  final int length = imageObjectList.length;
  const int size = 25;
  final int fullChunks = length ~/ size;
  final int remainingChunk = length % size;

  for (var i = 0; i < fullChunks; i++) {
    separatedList.add(imageObjectList.sublist(i * 10, (i + 1) * 10));
  }

  if (remainingChunk > 0) {
    separatedList.add(imageObjectList.sublist(fullChunks * 10));
  }

  return separatedList;
}

Future<bool> uploadChunkImages(List<ImageObject> imageList) async {
  print('URI: $uri');
  final request = http.MultipartRequest('POST', uri);
  Map<String, List<String>> data = {'ids': [], 'timestamps': []};

  // // Limit to 10 images
  // final imageObjectsToUpload = imageList.take(10).toList();

  for (var imageObject in imageList) {
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
    return true;
  } else {
    print('Upload failed with status: ${response.statusCode}');
    final responseBody = await response.stream.bytesToString();
    print('Response body: $responseBody');
    return false;
  }
}

Future<List<ImageObject>> uploadAllImages(
    List<ImageObject> imageList, BuildContext context) async {
  final List<List<ImageObject>> separatedList = chunkListIntoTens(imageList);
  List<bool> uploadResults = [];
  List<ImageObject> successfulUploads = [];

  try {
    final connectivityCheck =
        await http.get(uri).timeout(const Duration(seconds: 5));
    if (connectivityCheck.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Unable to connect to the server.')),
      );
      return [];
    }
  } on TimeoutException catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: Connection timed out.')),
    );
    return [];
  } on SocketException catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: No internet connection.')),
    );
    return [];
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
    return [];
  }

  for (var chunk in separatedList) {
    uploadResults.add(await uploadChunkImages(chunk));
    if (uploadResults.last) {
      successfulUploads.addAll(chunk);
    }
  }
  print('Upload results: ${uploadResults.toString()}');

  return successfulUploads;
}
