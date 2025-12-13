import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../helpers/app_palette.dart';
import '../l10n/app_localizations.dart';

class StateBadge extends ConsumerStatefulWidget {
  final String state;
  final DateTime closesAt;
  const StateBadge({super.key, required this.closesAt, required this.state});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StateBadgeState();
}

class _StateBadgeState extends ConsumerState<StateBadge> {
  Color? _badgeColor;
  String? _badgeText;

  void _calculateState({required String state, required DateTime date}) {
    switch (state) {
      case "opened":
        _badgeColor = Colors.green;
        _badgeText = AppLocalizations.of(context)!.openedBadgeLabel;
        return;
      case "dateSelection":
        _badgeColor = AppPalette.of(context).badgeColor.defaultColor;
        _badgeText = AppLocalizations.of(context)!.dateSelectionLabel;
        return;
      case "filmSelection":
        _badgeColor = AppPalette.of(context).badgeColor.defaultColor;
        _badgeText = AppLocalizations.of(context)!.filmSelectionLabel;
        return;
      case "closed":
        _badgeColor = CustomColors.gray;
        _badgeText = AppLocalizations.of(context)!.closedBadgeLabel;
        return;
    }

    if (date.isBefore(DateTime.now())) {
      _badgeColor = CustomColors.gray;
      _badgeText = AppLocalizations.of(context)!.closedBadgeLabel;
      return;
    }

    _badgeColor = Colors.white;
    _badgeText = AppLocalizations.of(context)!.inactiveBadgeLabel;
  }

  @override
  Widget build(BuildContext context) {
    _calculateState(state: widget.state, date: widget.closesAt);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _badgeColor!.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: _badgeColor!),
      ),
      child: Text(
        _badgeText!,
        style: CustomTypography.captionBolder.copyWith(color: _badgeColor),
      ),
    );
  }
}
