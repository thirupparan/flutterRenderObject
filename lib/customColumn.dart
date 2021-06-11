import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CustomColumn extends MultiChildRenderObjectWidget {
  CustomColumn({
    Key? key,
    List<Widget> children = const [],
    this.alignment = CustomColumnAlignment.center,
  }) : super(key: key, children: children);

  final CustomColumnAlignment alignment;
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCoustomColumn(alignment: alignment);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderCoustomColumn renderObject) {
    renderObject.alignment = alignment;
  }
}

class CustomColumnParentData extends ContainerBoxParentData<RenderBox> {
  int? flex;
}

enum CustomColumnAlignment {
  start,
  center,
}

class RenderCoustomColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CustomColumnParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CustomColumnParentData> {
  RenderCoustomColumn({
    required CustomColumnAlignment alignment,
  }) : _alignment = alignment;

  CustomColumnAlignment get alignment => _alignment;
  CustomColumnAlignment _alignment;

  set alignment(CustomColumnAlignment value) {
    if (value == _alignment) return;
    _alignment = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! CustomColumnParentData) {
      child.parentData = CustomColumnParentData();
    }
  }

  Size _performLayoit(
      {required BoxConstraints constraints, required bool dry}) {
    double width = 0, height = 0;
    int totalFlex = 0;

    RenderBox? lastFlexChild;

    // Laying out the fixed  height children.
    RenderBox? child = firstChild;

    while (child != null) {
      final childParentData = child.parentData as CustomColumnParentData;
      final flex = childParentData.flex ?? 0;
      if (flex > 0) {
        totalFlex += flex;
        lastFlexChild = child;
      } else {
        late final Size childSize;
        if (!dry) {
          child.layout(
            BoxConstraints(
              maxWidth: constraints.maxWidth,
            ),
            parentUsesSize: true,
          );
          childSize = child.size;
        } else {
          childSize = child.getDryLayout(
            BoxConstraints(
              maxWidth: constraints.maxWidth,
            ),
          );
        }

        height += childSize.height;
        width = max(width, childSize.width);
      }
      child = childParentData.nextSibling;
    }
// Distributing  the remaining height to flex children.
    final flexHight = (constraints.maxHeight - height) / totalFlex;
    child = lastChild;
    while (child != null) {
      final childParentData = child.parentData as CustomColumnParentData;
      final flex = childParentData.flex ?? 0;

      if (flex > 0) {
        final childHight = flexHight * flex;
        late final Size childSize;
        if (!dry) {
          child.layout(
            BoxConstraints(
              minHeight: childHight,
              maxHeight: childHight,
              maxWidth: constraints.maxWidth,
            ),
            parentUsesSize: true,
          );
          childSize = child.size;
        } else {
          childSize = child.getDryLayout(
            BoxConstraints(
              minHeight: childHight,
              maxHeight: childHight,
              maxWidth: constraints.maxWidth,
            ),
          );
        }
        height += childSize.height;
        width = max(width, childSize.width);
      }

      child = childParentData.previousSibling;
    }

    return Size(width, height);
  }

  @override
  void performLayout() {
    size = _performLayoit(constraints: constraints, dry: false);
    // Positioning the children
    RenderBox? child = firstChild;
    var childOffSet = Offset(0, 0);
    while (child != null) {
      final childParentData = child.parentData as CustomColumnParentData;
      childParentData.offset = Offset(
          alignment == CustomColumnAlignment.center
              ? (size.width - child.size.width) / 2
              : 0,
          childOffSet.dy);

      childOffSet += Offset(0, child.size.height);
      child = childParentData.nextSibling;
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _performLayoit(constraints: constraints, dry: true);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as CustomColumnParentData;

      height += child.getMinIntrinsicHeight(width);

      child = childParentData.nextSibling;
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double height = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as CustomColumnParentData;

      height += child.getMaxIntrinsicHeight(width);

      child = childParentData.nextSibling;
    }
    return height;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    double width = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as CustomColumnParentData;

      width = max(width, child.getMinIntrinsicWidth(width));

      child = childParentData.nextSibling;
    }
    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double width = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as CustomColumnParentData;

      width = max(width, child.getMinIntrinsicWidth(width));

      child = childParentData.nextSibling;
    }
    return width;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
