import 'package:flutter/widgets.dart';
import 'package:flutter_render_object/customColumn.dart';

class CustomExpaned extends ParentDataWidget<CustomColumnParentData> {
  const CustomExpaned({
    Key? key,
    this.flex = 1,
    required Widget child,
  })  : assert(flex > 0),
        super(key: key, child: child);
  final int flex;
  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as CustomColumnParentData;
    if (parentData.flex != flex) {
      parentData.flex = flex;

      final targetObject = renderObject.parent;
      if (targetObject is RenderObject) {
        targetObject.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => CustomColumn;
}
