import 'package:flutter/foundation.dart';
import 'package:myapp/core/enums/page_state.dart';

class BaseModel extends ChangeNotifier {
  PageState _state = PageState.Idle;

  PageState get state => _state;

  void setState(PageState viewState) {
    _state = viewState;
    notifyListeners();
  }
}
