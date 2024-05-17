import 'package:flutter/material.dart';

// リンク
class WebAccessLink {
  const WebAccessLink({
    required this.title,
    required this.url,
    required this.icon,
  });
  final String title;
  final String url;
  final IconData icon;
}
