import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test_multipart/etc/modal_sheets.dart';
import 'package:test_multipart/http/request_handler.dart';
import 'package:test_multipart/models/models.dart';
import 'package:test_multipart/providers/imagesProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageListView extends ConsumerStatefulWidget {
  const ImageListView({super.key});

  @override
  _ImageListViewState createState() => _ImageListViewState();
}

class _ImageListViewState extends ConsumerState<ImageListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(imageProvider.notifier).loadImagesFromDatabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageListProvider = ref.watch(imageProvider);
    var imageNotifier = ref.watch(imageProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () async {
              List<ImageObject> successfulUploads =
                  await uploadAllImages(imageListProvider, context);
              imageNotifier.removeListImages(successfulUploads);
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              imageNotifier.removeListImages(imageListProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.numbers),
            onPressed: () {
              print('Number of images: ${imageListProvider.length}');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: imageListProvider.length,
        itemBuilder: (BuildContext context, int index) {
          final image = imageListProvider[index];
          return Dismissible(
            key: ValueKey(image.id),
            onDismissed: (direction) => imageNotifier.removeImage(image.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              title: Text('Image ${image.id}'),
              leading: const Icon(Icons.image),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newImage = await callImagePickerModalBottomSheet(context);

          // Debuging purposes
          // Remove for loop and leave newImageObject and notifier calls
          if (newImage != null) {
            for (int i = 0; i < 116; i++) {
              File newCopiedImage =
                  await newImage.copy(newImage.path + i.toString());
              ImageObject newImageObject = ImageObject(image: newCopiedImage);
              imageNotifier.addImage(newImageObject);
              Future.delayed(const Duration(seconds: 1));
            }
          } else {
            print('No image selected');
            return;
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
