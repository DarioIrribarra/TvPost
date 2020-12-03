
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

enum ItemType { Text, Image, Image2 }

class EditableItem {
  Offset position = Offset(0.0, 0.0);
  double scale = 1.0;
  double rotation = 0.0;
  ItemType type;
  Text value;
  File valor;
  Uint8List byte;
}