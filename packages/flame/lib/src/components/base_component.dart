import 'dart:ui';

import 'package:meta/meta.dart';

import '../../game.dart';
import '../../input.dart';
import '../effects/effects.dart';
import '../effects/effects_handler.dart';
import '../extensions/vector2.dart';
import '../text.dart';
import 'component.dart';

/// This can be extended to represent a basic Component for your game.
///
/// The difference between this and [Component] is that the [BaseComponent] can
/// have children, handle effects and can be used to see whether a position on
/// the screen is on your component, which is useful for handling gestures.
abstract class BaseComponent extends Component {
  final EffectsHandler _effectsHandler = EffectsHandler();

  /// This is set by the BaseGame to tell this component to render additional
  /// debug information, like borders, coordinates, etc.
  /// This is very helpful while debugging. Set your BaseGame debugMode to true.
  /// You can also manually override this for certain components in order to
  /// identify issues.
  bool debugMode = false;

  Color debugColor = const Color(0xFFFF00FF);

  Paint get debugPaint => Paint()
    ..color = debugColor
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  TextPaint get debugTextPaint => TextPaint(
        config: TextPaintConfig(
          color: debugColor,
          fontSize: 12,
        ),
      );

  BaseComponent({int? priority}) : super(priority: priority);

  /// This method is called periodically by the game engine to request that your
  /// component updates itself.
  ///
  /// The time [dt] in seconds (with microseconds precision provided by Flutter)
  /// since the last update cycle.
  /// This time can vary according to hardware capacity, so make sure to update
  /// your state considering this.
  /// All components on [BaseGame] are always updated by the same amount. The
  /// time each one takes to update adds up to the next update cycle.
  @mustCallSuper
  @override
  void update(double dt) {
    children.updateComponentList();
    _effectsHandler.update(dt);
    children.forEach((c) => c.update(dt));
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    preRender(canvas);
  }

  @mustCallSuper
  @override
  void renderTree(Canvas canvas) {
    render(canvas);
    postRender(canvas);
    children.forEach((c) {
      canvas.save();
      c.renderTree(canvas);
      canvas.restore();
    });

    // Any debug rendering should be rendered on top of everything
    if (debugMode) {
      renderDebugMode(canvas);
    }
  }

  /// A render cycle callback that runs before the component and its children
  /// has been rendered.
  @protected
  void preRender(Canvas canvas) {}

  /// A render cycle callback that runs after the component has been
  /// rendered, but before any children has been rendered.
  void postRender(Canvas canvas) {}

  void renderDebugMode(Canvas canvas) {}

  /// Add an effect to the component
  void addEffect(ComponentEffect effect) {
    _effectsHandler.add(effect, this);
  }

  /// Mark an effect for removal on the component
  void removeEffect(ComponentEffect effect) {
    _effectsHandler.removeEffect(effect);
  }

  /// Remove all effects
  void clearEffects() {
    _effectsHandler.clearEffects();
  }

  /// Get a list of non removed effects
  List<ComponentEffect> get effects => _effectsHandler.effects;

  @protected
  Vector2 eventPosition(PositionInfo info) {
    return isHud ? info.eventPosition.widget : info.eventPosition.game;
  }
}
