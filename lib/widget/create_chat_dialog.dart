import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../consts/custom_colors.dart';
import '../consts/custom_typography.dart';
import '../consts/regex.dart';
import '../model/chat_item.dart';
import '../model/user_profile.dart';
import '../providers/chat_list.dart';
import '../providers/user_profiles.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import 'custom_input_field.dart';

class CreateChatDialog extends ConsumerStatefulWidget {
  const CreateChatDialog({super.key});

  static Future<String?> show({
    required BuildContext context,
    Future<void> Function()? function,
  }) {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return const CreateChatDialog();
      },
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateChatDialogState();
}

class _CreateChatDialogState extends ConsumerState<CreateChatDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _nameError;
  String? _dateError;
  String? _passwordError;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),

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
        _selectedTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final String hours = time.hour.toString().padLeft(2, '0');
    final String minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  DateTime? _getCombinedDateTime() {
    if (_selectedDate == null || _selectedTime == null) {
      return null;
    }
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  Future<ChatItem?> _createChat({required String userId}) async {
    setState(() {
      _dateError = null;
      _nameError = null;
      _passwordError = null;
    });

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = "Inserire un nome valido";
      });
    }

    if (_selectedDate == null) {
      setState(() {
        _dateError = "Inserire una data valida";
      });
    }

    if (_selectedTime == null) {
      setState(() {
        _dateError = "Inserire una data valida";
      });
    }

    if (!Regex.passwordRegex.hasMatch(_passwordController.text)) {
      _passwordError = "La password non rispecchia i canoni minimi";
    }

    if (_nameError != null || _dateError != null || _passwordError != null) {
      return null;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final DateTime combinedDateTime = _getCombinedDateTime()!;
      final ChatService service = ChatService();
      final UserService userService = UserService();

      final ChatItem chat = await service.createChat(
        name: _nameController.text,
        closesAt: combinedDateTime,
        createdBy: userId,
        password: _passwordController.text,
        description: _descriptionController.text,
      );

      await userService.addChat(userId, chat.id);

      if (mounted) {
        ref.invalidate(chatListProvider);
        ref.invalidate(userProfilesProvider);
        context.pop();
        return chat;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserProfile> loggedUser = ref.read(userProfilesProvider);
    return loggedUser.when(
      data: (UserProfile data) {
        return AlertDialog(
          backgroundColor: CustomColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  "Crea un gruppo",
                  style: CustomTypography.titleXL.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => context.pop(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.close),
                ),
              ),
            ],
          ),
          content: IntrinsicWidth(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomInputField(
                      fieldName: "Nome",
                      controller: _nameController,
                      errorMessage: _nameError,
                      textType: TextInputType.text,
                    ),
                    const SizedBox(height: 8),
                    CustomInputField(
                      fieldName: "Password",
                      controller: _passwordController,
                      hidden: true,
                      textType: TextInputType.visiblePassword,
                      errorMessage: _passwordError,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Descrizione (opzionale)",
                        style: CustomTypography.bodySmall,
                      ),
                    ),
                    SizedBox(
                      height: 90,
                      child: TextField(
                        controller: _descriptionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintStyle: CustomTypography.bodySmall,
                          filled: true,
                          fillColor: CustomColors.white.withValues(alpha: 0.7),
                          hintText: "Descrizione",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              width: 1,
                              color: CustomColors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              width: 1,
                              color: CustomColors.black,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              width: 1,
                              color: CustomColors.black,
                            ),
                          ),
                        ),
                        onTapOutside: (PointerDownEvent event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Data di chiusura",
                                  style: CustomTypography.bodySmall,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _selectDate(context),
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
                                      color: _dateError != null
                                          ? CustomColors.errorMessage
                                          : CustomColors.black,
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
                                          _selectedDate != null
                                              ? DateFormat(
                                                  'dd/MM/yy',
                                                ).format(_selectedDate!)
                                              : 'Data',
                                          style: CustomTypography.bodySmall
                                              .copyWith(
                                                color: _selectedDate != null
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Ora",
                                  style: CustomTypography.bodySmall,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _selectTime(context),
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
                                      color: _dateError != null
                                          ? CustomColors.errorMessage
                                          : CustomColors.black,
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
                                          _selectedTime != null
                                              ? _formatTime(_selectedTime!)
                                              : 'Ora',
                                          style: CustomTypography.bodySmall
                                              .copyWith(
                                                color: _selectedTime != null
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_dateError != null)
                      Padding(
                        padding: const EdgeInsetsGeometry.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Text(
                          _dateError!,
                          style: CustomTypography.caption.copyWith(
                            color: CustomColors.errorMessage,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            if (_isCreating)
              const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _createChat(userId: loggedUser.value!.userId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.lightBlue,
                  foregroundColor: CustomColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Crea gruppo',
                  style: CustomTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CustomColors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      error: (_, __) {
        return const Center(child: Text("Error"));
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
