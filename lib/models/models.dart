import 'dart:io';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class ImageObject {
  ImageObject({
    String? id,
    required this.image,
    DateTime? timestamp,
  }) : id = id ?? uuid.v4();

  final String id;
  final File image;
  final DateTime timestamp = DateTime.now().toUtc();

  @override
  String toString() {
    return 'ImageObject(id: $id, image: $image, timestamp: $timestamp)';
  }
}