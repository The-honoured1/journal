import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

ImageProvider getAvatarProvider(String? url) {
  if (url == null || url.isEmpty) {
    return const NetworkImage(
      "https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=150&auto=format&fit=crop&q=80",
    );
  }
  if (url.startsWith('http') || url.startsWith('blob:') || url.startsWith('data:')) {
    return NetworkImage(url);
  }
  if (kIsWeb) {
    return NetworkImage(url);
  }
  return FileImage(File(url));
}
