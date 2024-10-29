import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test_multipart/etc/image_picker.dart';

Future<File?> callImagePickerModalBottomSheet(BuildContext context) async {
  File? selectedImage;

  return showModalBottomSheet<File>(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            ImageInput(
              onPickImage: (image) {
                selectedImage = image;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedImage);
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      );
    },
  );
}
