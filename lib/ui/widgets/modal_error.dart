import 'package:crypto_tracker/ui/ui_constants/kcolors.dart';
import 'package:crypto_tracker/ui/ui_constants/labels.dart';
import 'package:crypto_tracker/ui/widgets/dialog_wrapper.dart';
import 'package:flutter/material.dart';

class ModalError extends StatelessWidget {
  const ModalError({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DialogWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(Labels.errorTitle(),
              style: theme.textTheme.headlineMedium!
                  .copyWith(color: kRedAccent)),
          SizedBox(height: 10),
          FractionallySizedBox(
            widthFactor: 1,
            child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(Labels.errorButton(),
                    style: theme.textTheme.bodyLarge)),
          )
        ],
      ),
    );
  }
}
