import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../l10n/app_localizations.dart';

class CustomDialog extends ConsumerWidget {
  final String title;
  final String subtitle;
  final Future<void> Function()? function;

  const CustomDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.function,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    Future<void> Function()? function,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: title,
          subtitle: subtitle,
          function: function,
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
                fontWeight: FontWeight.bold,
                color: CustomColors.black,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.close, fill: 0),
            ),
          ),
        ],
      ),
      content: Text(
        subtitle,
        style: CustomTypography.bodySmall.copyWith(color: CustomColors.black),
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
                if (function != null) {
                  await function!();
                }
                Navigator.of(context).pop(true);
              },
              child: Text(
                AppLocalizations.of(context)!.confirmLabel,
                style: CustomTypography.bodySmall.copyWith(
                  color: CustomColors.white,
                ),
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
              onPressed: () => context.pop(false),
              child: Text(
                AppLocalizations.of(context)!.cancelLabel,
                style: CustomTypography.bodySmall.copyWith(
                  color: CustomColors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
