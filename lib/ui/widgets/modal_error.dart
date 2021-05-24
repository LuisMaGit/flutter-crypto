import 'package:crypto_tracker/ui/widgets/dialog_wrapper.dart';
import 'package:flutter/material.dart';

class ModalError extends StatelessWidget {
  const ModalError({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Something went wrong',
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(color: Colors.redAccent)),
          SizedBox(height: 10),
          FractionallySizedBox(
            widthFactor: 1,
            child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Try again',
                    style: Theme.of(context).textTheme.bodyText1)),
          )
        ],
      ),
    );
  }
}
