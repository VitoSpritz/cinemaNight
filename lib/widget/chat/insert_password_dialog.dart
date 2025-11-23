import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../consts/custom_colors.dart';
import '../../consts/custom_typography.dart';
import '../../l10n/app_localizations.dart';

class InsertPasswordDialog extends ConsumerStatefulWidget {
  final String mainTitle;
  final String subtitle;
  final Future<void> Function(String password)? confirmFunction;

  const InsertPasswordDialog({
    super.key,
    required this.mainTitle,
    required this.subtitle,
    this.confirmFunction,
  });

  static Future<String?> show({
    required BuildContext context,
    required String mainTitle,
    required String subtitle,
    Future<void> Function(String password)? confirmFunction,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return InsertPasswordDialog(
          mainTitle: mainTitle,
          subtitle: subtitle,
          confirmFunction: confirmFunction,
        );
      },
    );
  }

  @override
  ConsumerState<InsertPasswordDialog> createState() =>
      _InsertPasswordDialogState();
}

class _InsertPasswordDialogState extends ConsumerState<InsertPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final String password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _errorMessage = "Inserisci una password";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.confirmFunction != null) {
        await widget.confirmFunction!(password);
      }

      if (mounted) {
        Navigator.of(context).pop(password);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Password errata";
          _isLoading = false;
        });
      }
    }
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
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(widget.mainTitle, style: CustomTypography.titleXL),
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
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.subtitle,
              style: CustomTypography.body.copyWith(color: CustomColors.gray),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _isObscured,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "Inserisci la password",
                filled: true,
                fillColor: CustomColors.white.withValues(alpha: 0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _errorMessage != null
                        ? CustomColors.errorMessage
                        : CustomColors.black,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _errorMessage != null
                        ? CustomColors.errorMessage
                        : CustomColors.black,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _errorMessage != null
                        ? CustomColors.errorMessage
                        : CustomColors.lightBlue,
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                    color: CustomColors.gray,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
              ),
              onSubmitted: (_) => _handleConfirm(),
              onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: CustomTypography.bodySmall.copyWith(
                    color: CustomColors.errorMessage,
                  ),
                ),
              ),
          ],
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
                  backgroundColor: CustomColors.black,
                ),
                onPressed: _isLoading ? null : _handleConfirm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: CustomColors.white,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.confirmLabel,
                        style: const TextStyle(color: CustomColors.white),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
