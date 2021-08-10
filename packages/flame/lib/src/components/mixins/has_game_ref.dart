import '../../../components.dart';
import '../../../game.dart';

mixin HasGameRef<T extends Game> on Component {
  T? _gameRef;

  T get gameRef {
    if (_gameRef == null) {
      var c = parent;
      while (c != null) {
        if (c is HasGameRef<T> && c._gameRef != null) {
          _gameRef = c._gameRef;
          return _gameRef!;
        } else if (c is T) {
          _gameRef = c;
          return c;
        } else {
          c = c.parent;
        }
      }
      throw StateError('Cannot find reference $T in the component tree');
    }
    return _gameRef!;
  }

  @override
  void onRemove() {
    super.onRemove();
    _gameRef = null;
  }
}
