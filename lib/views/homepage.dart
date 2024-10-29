import 'package:flutter/material.dart';
import 'package:test_multipart/etc/modal_sheets.dart';
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
  Widget build(BuildContext context) {
    final imageListProvider = ref.watch(imageProvider);
    var imageNotifier = ref.watch(imageProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image List'),
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

          if (newImage != null) {
            ImageObject newImageObject = ImageObject(image: newImage);
            imageNotifier.addImage(newImageObject);
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
