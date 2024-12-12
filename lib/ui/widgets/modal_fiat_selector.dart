import 'package:crypto_tracker/data/crypto_data_service/crypto_data_constants.dart';
import 'package:crypto_tracker/ui/ui_constants/labels.dart';
import 'package:crypto_tracker/ui/widgets/dialog_wrapper.dart';
import 'package:crypto_tracker/ui/ui_helpers.dart';
import 'package:flutter/material.dart';

class ModalFiatSelector extends StatelessWidget {
  final FiatCode selected;

  const ModalFiatSelector({
    Key? key,
    required this.selected,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DialogWrapper(
      child: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: [
          Text(Labels.modalFiatSelectorTitle(),
              style: theme.textTheme.headlineMedium),
          SizedBox(height: 10),
          ...FiatCode.values.map((f) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop(f);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  UIHelper.fiatName[f] ?? '',
                  style: selected == f
                      ? theme.textTheme.bodyLarge
                      : theme.textTheme.bodyLarge!.copyWith(
                          color: theme.colorScheme.tertiary,
                        ),
                ),
              ),
            );
          }).toList()
        ],
      ),
    );
  }
}
