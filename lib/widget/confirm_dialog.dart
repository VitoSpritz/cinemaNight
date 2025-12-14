import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../helpers/app_palette.dart';
import '../l10n/app_localizations.dart';

class ConfirmDialog extends ConsumerWidget {
  final String title;
  final String subtitle;
  final Future<void> Function()? confirmFunction;
  final Future<void> Function()? cancelFunction;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.confirmFunction,
    this.cancelFunction,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    Future<void> Function()? confirmFunction,
    Future<void> Function()? cancelFunction,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: title,
          subtitle: subtitle,
          confirmFunction: confirmFunction,
          cancelFunction: cancelFunction,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      scrollable: true,
      backgroundColor: CustomColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: CustomTypography.titleXL.copyWith(
                color: AppPalette.of(context).textColors.simpleText,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => context.pop(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: AppPalette.of(context).textColors.simpleText,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        subtitle,
        style: CustomTypography.titleM.copyWith(
          color: AppPalette.of(context).textColors.simpleText,
        ),
      ),
      actions: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FilledButton(
              style: FilledButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
                backgroundColor: CustomColors.mainYellow,
              ),
              onPressed: () async {
                if (confirmFunction != null) {
                  await confirmFunction!();
                }
                Navigator.of(context).pop(true);
              },
              child: Text(
                AppLocalizations.of(context)!.confirmLabel,
                style: const TextStyle(color: CustomColors.white),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: CustomColors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  side: BorderSide(color: CustomColors.black, width: 1),
                ),
              ),
              onPressed: () async {
                if (cancelFunction != null) {
                  await cancelFunction!();
                }
                context.pop(false);
              },
              child: Text(
                AppLocalizations.of(context)!.cancelLabel,
                style: const TextStyle(color: CustomColors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
