import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_render_object/coustomBox.dart';
import 'package:flutter_render_object/customColumn.dart';
import 'package:flutter_render_object/customExpaned.dart';
import 'package:flutter_render_object/customProxy.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Center(
        child: Container(
          width: 400,
          // color: Colors.brown,
          child: Foo(),
          //     ProgressBar(
          //   dotColor: Colors.blue,
          //   thumbColor: Colors.blue,
          //   thumbSize: 10,
          // ),
        ),
      ),
    );
  }
}

class ProgressBar extends LeafRenderObjectWidget {
  const ProgressBar({
    Key? key,
    this.dotColor,
    this.thumbColor,
    this.thumbSize,
  }) : super(key: key);

  final Color? dotColor;
  final Color? thumbColor;
  final double? thumbSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderProgressBar(
        dotColor: dotColor, thumbColor: thumbColor, thumbSize: thumbSize);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderProgressBar renderObject) {
    renderObject
      ..dotColor = dotColor!
      ..thumbColor = thumbColor!
      ..thumbSize = thumbSize!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('dotColor', dotColor));
    properties.add(ColorProperty('thumbColor', thumbColor));
    properties.add(DoubleProperty('thumbSize', thumbSize));
  }
}

class RenderProgressBar extends RenderBox {
  RenderProgressBar({
    Color? dotColor,
    Color? thumbColor,
    double? thumbSize,
  })  : _dotColor = dotColor!,
        _thumbColor = thumbColor!,
        _thumbSize = thumbSize! {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = (DragStartDetails details) {
        _updateThumbPosition(details.localPosition);
      }
      ..onUpdate = (DragUpdateDetails details) {
        _updateThumbPosition(details.localPosition);
      };
  }

  double _currentThumbValue = 0.5;

  Color get dotColor => _dotColor;
  Color _dotColor;
  set dotColor(Color value) {
    if (_dotColor == value) {
      return;
    }
    _dotColor = value;
    markNeedsPaint();
  }

  Color get thumbColor => _thumbColor;
  Color _thumbColor;
  set thumbColor(Color value) {
    if (_thumbColor == value) {
      return;
    }
    _thumbColor = value;
    markNeedsPaint();
  }

  double get thumbSize => _thumbSize;
  double _thumbSize;
  set thumbSize(double value) {
    if (_thumbSize == value) {
      return;
    }
    _thumbSize = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final desiredWidth = constraints.maxWidth;
    final desiredHeight = thumbSize;
    final desiredSize = Size(desiredWidth, desiredHeight);
    size = constraints.constrain(desiredSize);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    // Paint dots

    final dotPaint = Paint()
      ..color = dotColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    final barPaint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    final spacing = size.width / 10;
    for (var i = 0; i < 11; i++) {
      var upperPoint = Offset(spacing * i, size.height * 0.75);
      final lowerPoint = Offset(spacing * i, size.height);

      if (i % 5 == 0) {
        upperPoint = Offset(spacing * i, size.height * 0.25);
      }
      if (upperPoint.dx <= _currentThumbValue * size.width) {
        canvas.drawLine(upperPoint, lowerPoint, barPaint);
      }
      canvas.drawLine(upperPoint, lowerPoint, dotPaint);
    }

    // setUp thumb
    final thumbPaint = Paint()..color = thumbColor;
    final thumbDx = _currentThumbValue * size.width;

    // draw the bar from left to thum position
    final point1 = Offset(0, size.height / 2);
    final point2 = Offset(thumbDx, size.height / 2);
    canvas.drawLine(point1, point2, barPaint);

    // Paint Thumb
    final center = Offset(thumbDx, size.height / 2);
    canvas.drawCircle(center, thumbSize, thumbPaint);

    canvas.restore();
    super.paint(context, offset);
  }

  // define our variable
  HorizontalDragGestureRecognizer? _drag;
  // Render object can be hit
  @override
  bool hitTestSelf(Offset position) => true;

  // Handle the hit event and send that to our HorizontalDragGestureRecognizer.
  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _drag!.addPointer(event);
    }
  }

  @override
  void detach() {
    _drag!.dispose();
    super.detach();
  }

  void _updateThumbPosition(Offset localPosition) {
    // clamp the position between the full width of the renderobject
    // to avoid if you drag the mouse out of the window.
    var dx = localPosition.dx.clamp(0, size.width);

    // make the size between 0 and 1 with only 1 decimal
    // example 0.4 or 0.7.
    _currentThumbValue = double.parse((dx / size.width).toStringAsFixed(1));

    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }
}

class Foo extends StatefulWidget {
  const Foo({Key? key}) : super(key: key);

  @override
  _FooState createState() => _FooState();
}

class _FooState extends State<Foo> with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomColumn(
            alignment: CustomColumnAlignment.center,
            children: [
              // const Spacer(),
              const CustomExpaned(
                // CustomBox(
                flex: 2,
                child: SizedBox(),
                // color: Color(0x00ffffff),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  'A definitive guid to\n RenderObjects in Flutter',
                  style: TextStyle(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'by Thiru',
                  textAlign: TextAlign.center,
                ),
              ),
              // const Spacer(),
              AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomBox(
                      onTap: () {
                        if (_controller.isAnimating) {
                          _controller.stop();
                          return;
                        }
                        _controller.repeat();
                      },
                      flex: 3, color: Color(0xafdf32a4),
                      rotation: _controller.value * 2 * pi,
                      // child: SizedBox(),
                    );
                  }),
            ],
          ),
          CustomProxy(
            child: SizedBox.expand(
              child: Image.network(
                'https://i0.wp.com/www.greattopten.com/wp-content/uploads/2020/08/Hritik-Roshan.jpg?fit=620%2C450&ssl=1',
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
      ),
    );
  }
}
