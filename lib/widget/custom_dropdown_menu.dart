import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../consts/custom_colors.dart';
import '../l10n/app_localizations.dart';

class CustomDropdownMenu extends ConsumerWidget {
  final List<String> values;
  final Function() onSelectedItem;

  const CustomDropdownMenu(this.values, this.onSelectedItem, {super.key});

  static Future<String?> showModal({
    required List<String> values,
    required BuildContext context,
    required Function() onSelectedItem,
  }) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CustomDropdownMenu(values, onSelectedItem);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      alignment: Alignment.topCenter,
      scrollable: true,
      backgroundColor: CustomColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.customDropdownMenuSelectAGenre,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SizedBox(
                height: 500,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: values.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1, thickness: 1),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        onSelectedItem();
                        context.pop(values[index]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Text(
                          values[index],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
