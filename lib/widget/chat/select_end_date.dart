import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../consts/custom_colors.dart';
import '../../consts/custom_typography.dart';
import '../../l10n/app_localizations.dart';

class SelectEndDate extends StatefulWidget {
  const SelectEndDate({super.key});

  @override
  State<SelectEndDate> createState() => _SelectEndDateState();
}

class _SelectEndDateState extends State<SelectEndDate> {
  DateTime? _selectedDateTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime maxDate = now.add(const Duration(hours: 48));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now,
      firstDate: now,
      lastDate: maxDate,
      locale: const Locale('it', 'IT'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CustomColors.lightBlue,
              onPrimary: CustomColors.white,
              onSurface: CustomColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay initialTime = _selectedDateTime != null
          ? TimeOfDay.fromDateTime(_selectedDateTime!)
          : TimeOfDay.now();

      if (context.mounted) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: CustomColors.lightBlue,
                  onPrimary: CustomColors.white,
                  onSurface: CustomColors.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          final DateTime combined = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (combined.isAfter(maxDate)) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.selectEndDateSelectDate,
                  ),
                ),
              );
            }
            return;
          }

          setState(() {
            _selectedDateTime = combined;
          });
        }
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectEndDateSelctTime),
        ),
      );
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime!),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CustomColors.lightBlue,
              onPrimary: CustomColors.white,
              onSurface: CustomColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final DateTime combined = DateTime(
        _selectedDateTime!.year,
        _selectedDateTime!.month,
        _selectedDateTime!.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      final DateTime now = DateTime.now();
      final DateTime maxDate = now.add(const Duration(hours: 48));

      if (combined.isAfter(maxDate)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.selectEndDateSelectDate,
              ),
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedDateTime = combined;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
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
                AppLocalizations.of(context)!.selectEndDateSelctTime,
                style: CustomTypography.titleXL.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.selectEndDateSelectLimitDate,
                style: CustomTypography.caption,
              ),
              const Spacer(),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () async {
                        await _selectDate(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: CustomColors.white.withValues(alpha: 0.7),
                          border: Border.all(
                            color: CustomColors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                _selectedDateTime != null
                                    ? _formatDate(_selectedDateTime!)
                                    : AppLocalizations.of(
                                        context,
                                      )!.selectEndDateSelectaDate,
                                style: CustomTypography.bodySmall.copyWith(
                                  color: _selectedDateTime != null
                                      ? CustomColors.black
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: CustomColors.lightBlue,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () async {
                        await _selectTime(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: CustomColors.white.withValues(alpha: 0.7),
                          border: Border.all(
                            color: CustomColors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                _selectedDateTime != null
                                    ? _formatTime(_selectedDateTime!)
                                    : AppLocalizations.of(
                                        context,
                                      )!.selectEndDateTime,
                                style: CustomTypography.bodySmall.copyWith(
                                  color: _selectedDateTime != null
                                      ? CustomColors.black
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.access_time,
                              color: CustomColors.lightBlue,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  backgroundColor: CustomColors.mainYellow,
                ),
                onPressed: () async {
                  if (_selectedDateTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                            context,
                          )!.selectEndDateSelectaDateTime,
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).pop(_selectedDateTime);
                },
                child: Text(
                  AppLocalizations.of(context)!.confirmLabel,
                  style: CustomTypography.bodySmall.copyWith(
                    color: CustomColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: CustomColors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    side: BorderSide(color: CustomColors.black, width: 1),
                  ),
                ),
                onPressed: () => context.pop(null),
                child: Text(
                  AppLocalizations.of(context)!.cancelLabel,
                  style: CustomTypography.bodySmall.copyWith(
                    color: CustomColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
