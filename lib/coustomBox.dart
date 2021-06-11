import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_render_object/customColumn.dart';

class CustomBox extends LeafRenderObjectWidget {
  const CustomBox({
    Key? key,
    this.flex = 0,
    required this.color,
    this.rotation = 0,
    this.onTap,
  })  : assert(
          rotation <= 2 * pi && rotation >= 0,
        ),
        super(key: key);
  final int flex;
  final Color color;
  final double rotation;

  final VoidCallback? onTap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomBox(
      flex: flex,
      color: color,
      rotation: rotation,
      onTab: onTap!,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCustomBox renderObject) {
    renderObject
      ..flex = flex
      ..color = color
      ..rotation = rotation
      ..onTab = onTap;
  }
}

class RenderCustomBox extends RenderBox {
  RenderCustomBox({
    required int flex,
    required Color color,
    required double rotation,
    required VoidCallback onTab,
  })  : _flex = flex,
        _color = color,
        _rotation = rotation,
        _onTab = onTab;

  int get flex => _flex;
  int _flex;

  set flex(int value) {
    assert(value >= 0);
    if (value == flex) return;
    _flex = value;
    parentData!.flex = flex;
    markParentNeedsLayout();
  }

  Color get color => _color;
  Color _color;

  set color(Color value) {
    if (value == color) return;
    _color = value;
    markNeedsPaint();
  }

  double get rotation => _rotation;
  double _rotation;

  set rotation(double value) {
    if (value == rotation) return;
    _rotation = value;
    markNeedsPaint();
  }

  VoidCallback? get onTab => _onTab;
  VoidCallback? _onTab;

  set onTab(VoidCallback? value) {
    if (value == onTab) return;
    _onTab = value;
    markNeedsSemanticsUpdate();
    _tapGestureRecognizer.onTap = onTab;
  }

  // @override
  // bool get isRepaintBoundary => true;

  @override
  CustomColumnParentData? get parentData {
    if (super.parentData == null) return null;
    assert(super.parentData is CustomColumnParentData,
        '$CustomBox can only be a direct child of a $CustomColumn.');

    return super.parentData as CustomColumnParentData;
  }

  late final TapGestureRecognizer _tapGestureRecognizer;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    parentData!.flex = flex;
    _tapGestureRecognizer = TapGestureRecognizer(debugOwner: this)
      ..onTap = onTab;
  }

  @override
  void detach() {
    _tapGestureRecognizer.dispose();
    super.detach();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    config
      ..isButton = true
      ..textDirection = TextDirection.ltr
      ..hint = 'Trigger spinning animation'
      ..onTap = onTab;
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  bool hitTestSelf(Offset position) {
    return size.contains(position);
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));

    if (event is PointerDownEvent) {
      _tapGestureRecognizer.addPointer(event);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // draw Background
    canvas.drawRect(offset & size, Paint()..color = color);

    final smallestRectWidth = size.shortestSide / (3 - sin(rotation));

    // draw small rectangle
    canvas.save();
    canvas.translate(
      offset.dx + size.width / 2,
      offset.dy + size.height / 2,
    );
    canvas.rotate(rotation);
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset.zero,
          width: smallestRectWidth,
          height: smallestRectWidth),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = const Color(0xff6a45df),
    );
    canvas.restore();
  }
}
