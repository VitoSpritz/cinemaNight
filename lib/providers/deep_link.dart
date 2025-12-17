import 'package:app_links/app_links.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../consts/global_state.dart';

part 'deep_link.g.dart';

@Riverpod(keepAlive: true)
AppLinks appLinks(Ref ref) {
  return AppLinks();
}

@Riverpod(keepAlive: true)
Stream<void> deepLinkListener(Ref ref) async* {
  final AppLinks appLinks = ref.watch(appLinksProvider);

  await Future<void>.delayed(const Duration(milliseconds: 800));

  final Uri? initialUri = await appLinks.getInitialLink();
  if (initialUri != null && initialUri.host.isNotEmpty) {
    handleDeepLink(initialUri);
  }

  appLinks.uriLinkStream.listen((Uri uri) {
    if (uri.host.isNotEmpty) {
      handleDeepLink(uri);
    }
  });
}

void handleDeepLink(Uri uri) {
  final BuildContext? context = GlobalState.navigatorKey.currentContext;
  if (context == null) {
    return;
  }

  final GoRouter router = GoRouter.of(context);

  if (uri.host == 'review' && uri.pathSegments.length >= 2) {
    final String reviewId = uri.pathSegments[0];
    router.goNamed(
      'reviewInfo',
      pathParameters: <String, String>{'reviewId': reviewId},
    );
  }
}
