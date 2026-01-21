import 'package:flutter/material.dart';

import 'link_types.dart';

abstract class LinkHandler {
  bool canHandle(String url);

  Future<LinkNavigateResult> navigate(
    BuildContext context,
    String url, {
    LinkNavigateMode mode = LinkNavigateMode.push,
  });
}
