import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../consts/custom_colors.dart';
import '../../consts/custom_typography.dart';
import '../../l10n/app_localizations.dart';

class SelectDatesDialog extends StatefulWidget {
  const SelectDatesDialog({super.key});

  @override
  State<SelectDatesDialog> createState() => _SelectDatesDialogState();
}

class _SelectDatesDialogState extends State<SelectDatesDialog> {
  bool _checkBoxState = false;
  final List<DateTime?> _selectedDates = <DateTime?>[];
  static const int _maxDates = 5;

  Future<void> _selectDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDates.length > index && _selectedDates[index] != null
          ? _selectedDates[index]!
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (picked != null) {
      setState(() {
        while (_selectedDates.length <= index) {
          _selectedDates.add(null);
        }
        _selectedDates[index] = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
                "Seleziona una data",
                style: CustomTypography.titleXL.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("Aggiungi più date", style: CustomTypography.caption),
                  Checkbox(
                    value: _checkBoxState,
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _checkBoxState = newValue;
                          if (!newValue) {
                            _selectedDates.clear();
                          }
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (_checkBoxState == false)
                GestureDetector(
                  onTap: () async {
                    await _selectDate(context, 0);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: CustomColors.white.withValues(alpha: 0.7),
                      border: Border.all(color: CustomColors.black, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _selectedDates.isNotEmpty &&
                                    _selectedDates[0] != null
                                ? _formatDate(_selectedDates[0]!)
                                : 'Seleziona data',
                            style: CustomTypography.bodySmall.copyWith(
                              color:
                                  _selectedDates.isNotEmpty &&
                                      _selectedDates[0] != null
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
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (int i = 0; i < _selectedDates.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      await _selectDate(context, i);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CustomColors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        border: Border.all(
                                          color: CustomColors.black,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              _selectedDates[i] != null
                                                  ? _formatDate(
                                                      _selectedDates[i]!,
                                                    )
                                                  : 'Data ${i + 1}',
                                              style: CustomTypography.bodySmall
                                                  .copyWith(
                                                    color:
                                                        _selectedDates[i] !=
                                                            null
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
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDates.removeAt(i);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                        if (_selectedDates.length < _maxDates)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDates.add(null);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: CustomColors.white.withValues(
                                  alpha: 0.7,
                                ),
                                border: Border.all(
                                  color: CustomColors.lightBlue,
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Icon(
                                    Icons.add,
                                    color: CustomColors.lightBlue,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Aggiungi una data',
                                    style: CustomTypography.bodySmall.copyWith(
                                      color: CustomColors.lightBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              if (_checkBoxState == false) const Spacer(),

              const SizedBox(height: 16),

              FilledButton(
                style: FilledButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  backgroundColor: CustomColors.mainYellow,
                ),
                onPressed: () async {
                  if (_selectedDates.isEmpty ||
                      _selectedDates.any((DateTime? date) => date == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Seleziona almeno una data'),
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).pop(_selectedDates);
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
