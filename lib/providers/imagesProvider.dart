import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:test_multipart/models/models.dart';
import 'package:test_multipart/providers/databases.dart';

class ImagesProvider extends StateNotifier<List<ImageObject>> {
  ImagesProvider() : super([]);

  Future<void> loadImagesFromDatabase() async {
    final db = await getDatabase();

    var imageListQuery = await db.query('images');

    final List<ImageObject> imageList = imageListQuery
        .map((row) => ImageObject(
              image: File(row['image_path'] as String),
              id: row['id'] as String,
              timestamp:
                  DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
            ))
        .toList();

    state = imageList;
  }

  Future<void> addImage(ImageObject imageObject) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(imageObject.image.path);
    final newFilename =
        filename + imageObject.timestamp.millisecondsSinceEpoch.toString();
    final savedImage =
        await imageObject.image.copy('${appDir.path}/$newFilename');
    state = [...state, ImageObject(image: savedImage)];
  }

  void removeImage(String id) {
    File image = state.firstWhere((element) => element.id == id).image;
    image.delete();
    state.removeWhere((element) => element.id == id);
  }
}

final imageProvider = StateNotifierProvider<ImagesProvider, List<ImageObject>>(
    (ref) => ImagesProvider());
