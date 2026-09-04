import 'package:flutter/material.dart';

import '../network/api_endpoints.dart';

/// Resolves a profile avatar value returned by the API into a [DecorationImage]
/// for [BoxDecoration]. Handles absolute URLs and server-relative `/uploads/...`
/// paths (resolved against the API host), falling back to the bundled placeholder
/// asset when no usable value is provided.
DecorationImage avatarDecoration(String? raw, {BoxFit fit = BoxFit.cover}) {
  final value = raw;
  if (value != null && value.isNotEmpty) {
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      return DecorationImage(image: NetworkImage(value), fit: fit);
    }
    if (value.startsWith('/')) {
      final base = Uri.parse(ApiEndpoints.baseUrl);
      return DecorationImage(
        image: NetworkImage('${base.scheme}://${base.host}$value'),
        fit: fit,
      );
    }
  }
  return DecorationImage(
    image: const AssetImage('assets/images/avatar.png'),
    fit: fit,
  );
}