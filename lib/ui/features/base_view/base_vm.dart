import 'package:crypto_tracker/ui/features/base_view/base_view_state.dart';
import 'package:flutter/foundation.dart';

abstract class BaseVM extends ChangeNotifier {
  BaseViewState state = BaseViewState.Bussy;

  set setState(BaseViewState value) {
    state = value;
    notifyListeners();
  }
}


