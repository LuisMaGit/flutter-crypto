import 'package:crypto_tracker/ui/views/main_view/main_view_models.dart';
import 'package:crypto_tracker/ui/widgets/dialog_wrapper.dart';
import 'package:crypto_tracker/utils/binders.dart';
import 'package:flutter/material.dart';

class ModalFiatSelector extends StatelessWidget {
  final FiatCode selected;

  const ModalFiatSelector({
    Key? key,
    required this.selected,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      child: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: [
          Text('Select fiat currency:',
              style: Theme.of(context).textTheme.headline2),
          SizedBox(height: 10),
          ...FiatCode.values.map((f) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop(f);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  Binders.fiatName[f] ?? '',
                  style: selected == f
                      ? Theme.of(context).textTheme.bodyText1
                      : Theme.of(context).textTheme.bodyText1!.copyWith(
                          color:
                              Theme.of(context).colorScheme.secondaryVariant),
                ),
              ),
            );
          }).toList()
        ],
      ),
    );
  }
}
