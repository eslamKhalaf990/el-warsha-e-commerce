import 'dart:typed_data';
import 'package:flutter/material.dart';

class DragDropController extends ChangeNotifier {
  List<Uint8List> images = [];

  void addImages(List<Uint8List> newImages) {
    images.addAll(newImages);
    notifyListeners();
  }

  void removeImage(int index) {
    images.removeAt(index);
    notifyListeners();
  }

  void clear() {
    images.clear();
    notifyListeners();
  }
}