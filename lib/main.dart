import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_demo_animation/utils/number_utils.dart';
import 'package:flutter_demo_animation/painters/rotating_wheel_painter.dart';
import 'package:flutter_demo_animation/painters/side_bar_painter.dart';
import 'package:flutter_demo_animation/painters/zooming_wheel_painter.dart';

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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScaleWheel(),
    );
  }
}

class ScaleWheel extends StatefulWidget {
  @override
  _WheelState createState() => _WheelState();
}

class _WheelState extends State<ScaleWheel> with TickerProviderStateMixin {
  final double _rotatingWheelDiameter = 670;
  double _rotatingWheelDegree = 0;
  AnimationController _rotatingCtrl;
  AnimationController _zoomingCtrl;
  bool _panDown;
  bool _panLeft;
  double _zoomingWheelScale;
  Offset _startingOffset;
  bool _continueRotating;
  bool _continueZooming;
  double _totalHorizontalChange;

  @override
  void initState() {
    super.initState();
    _rotatingCtrl = AnimationController.unbounded(vsync: this);
    _rotatingWheelDegree = 0;
    _rotatingCtrl.value = _rotatingWheelDegree;
    _continueRotating = false;
    _panDown = false;

    _zoomingCtrl = AnimationController.unbounded(vsync: this);
    _zoomingWheelScale = 0;
    _totalHorizontalChange = 0;
    _continueZooming = false;
    _panLeft = false;
  }

  double _nextRotatingDegree(double number, int base) {
    double reminder = number % base;
    double result = number;
    if (!_panDown) {
      result = number - reminder;
    } else {
      result = number + (base - reminder);
    }
    return result;
  }

  _panStartHandler(DragStartDetails d) {
    _startingOffset = d.localPosition;
    _totalHorizontalChange = 0;
  }

  _panUpdateHandler(DragUpdateDetails d) {
    double rotatingWheelRadius = _rotatingWheelDiameter / 2;

    /// Pan location on the wheel
    bool onTop = d.localPosition.dy <= rotatingWheelRadius;
    bool onLeftSide = d.localPosition.dx <= rotatingWheelRadius;
    bool onRightSide = !onLeftSide;
    bool onBottom = !onTop;

    /// Pan movements
    bool panUp = d.delta.dy <= 0.0;
    bool panLeft = d.delta.dx <= 0.0;
    bool panRight = !panLeft;
    bool panDown = !panUp;

    _panDown = panDown;
    _panLeft = panLeft;

    /// Absolute change on axis
    double yChange = d.delta.dy.abs();
    double xChange = d.delta.dx.abs();

    double dragAngle = atan((_startingOffset.dx - d.localPosition.dx) /
        (_startingOffset.dy - d.localPosition.dy));
    dragAngle = NumberUtils.radianToDegrees(dragAngle).abs();

    _zoomWheelWithDrag(
      dragAngle: dragAngle,
      xChange: xChange,
      onTop: onTop,
      panRight: panRight,
      onBottom: onBottom,
      panLeft: panLeft,
    );
    _rotateWheelWithDrag(
      dragAngle: dragAngle,
      yChange: yChange,
      onRightSide: onRightSide,
      panDown: panDown,
      onLeftSide: onLeftSide,
      panUp: panUp,
    );
  }

  void _zoomWheelWithDrag({
    double dragAngle,
    double xChange,
    bool onTop,
    bool panRight,
    bool onBottom,
    bool panLeft,
  }) {
    // do not zoom if the drag is not nearly horizontal
    if (dragAngle <= 35) {
      if (_continueZooming == true) _continueZooming = false;
      return;
    }
    if (_continueZooming == false) _continueZooming = true;

    /// Directional change on wheel
    double horizontalRotation =
        (onTop && panRight) || (onBottom && panLeft) ? xChange : xChange * -1;
    _totalHorizontalChange += horizontalRotation;

    if (_totalHorizontalChange > 200) _totalHorizontalChange = 200;
    if (_totalHorizontalChange < 0) _totalHorizontalChange = 200;

    _zoomingWheelScale = _totalHorizontalChange / 200;
    _zoomingCtrl.value = _zoomingWheelScale;
  }

  void _rotateWheelWithDrag({
    double dragAngle,
    double yChange,
    bool onRightSide,
    bool panDown,
    bool onLeftSide,
    bool panUp,
  }) {
    // do not rotate if the drag is nearly horizontal
    if (dragAngle > 35) {
      if (_continueRotating == true) _continueRotating = false;
      return;
    }
    if (_continueRotating == false) _continueRotating = true;

    if (_zoomingWheelScale > 0.9) {
      _zoomingWheelScale = 0;
      _zoomingCtrl.value = _zoomingWheelScale;
    }

    /// Directional change on wheel
    double rotationalChange = (onRightSide && panDown) || (onLeftSide && panUp)
        ? yChange
        : yChange * -1;

    _rotatingWheelDegree += rotationalChange / 15;
    _rotatingCtrl.value = _rotatingWheelDegree;
  }

  void _rotateWheelWithAnimation() {
    double nextRotatingDegree =
        _nextRotatingDegree(_rotatingWheelDegree.roundToDouble(), 36);

    _rotatingCtrl
        .animateTo(nextRotatingDegree,
            duration: Duration(milliseconds: 551), curve: Curves.easeOut)
        .whenComplete(() {
      _rotatingWheelDegree = nextRotatingDegree;
      _zoomWheelWithAnimation(toStart: false);
    });
  }

  void _zoomWheelWithAnimation({bool toStart}) {
    double nextZoomingScale = toStart ? 0 : 1;

    _zoomingCtrl
        .animateTo(nextZoomingScale,
            duration: Duration(milliseconds: 200), curve: Curves.easeOut)
        .whenComplete(() {
      _zoomingWheelScale = nextZoomingScale;
    });
  }

  void _panEndHandler(_) {
    if (_continueRotating) {
      _rotateWheelWithAnimation();
    }
    if (_continueZooming) {
      _zoomWheelWithAnimation(toStart: !_panLeft);
    }
  }

  @override
  void dispose() {
    _rotatingCtrl.dispose();
    _zoomingCtrl.dispose();
    super.dispose();
  }

  double get _screenHeight => MediaQuery.of(context).size.height;
  double get _screenWidth => MediaQuery.of(context).size.width;

  Widget get _sideBar => AnimatedBuilder(
        animation: _zoomingCtrl,
        builder: (ctx, w) {
          return CustomPaint(painter: SideBarPainter(_zoomingCtrl.value));
        },
      );
  Widget get _zoomingWheel => AnimatedBuilder(
        animation: _zoomingCtrl,
        child: Center(child: CustomPaint(painter: ZoomingWheelPainter())),
        builder: (ctx, w) {
          return FadeTransition(
              opacity: _zoomingCtrl,
              child: Transform.scale(scale: _zoomingCtrl.value, child: w));
        },
      );
  Widget get _rotatingWheel => AnimatedBuilder(
        animation: _rotatingCtrl,
        builder: (ctx, w) {
          return Transform.rotate(
            angle: NumberUtils.degreeToRadians(_rotatingCtrl.value),
            child: SizedBox(
              width: _rotatingWheelDiameter,
              height: _rotatingWheelDiameter,
              child: Center(
                child: CustomPaint(
                  painter: RotatingWheelPainter(_rotatingCtrl.value,
                      diameter: _rotatingWheelDiameter, context: context),
                ),
              ),
            ),
          );
        },
      );
  Widget get _draggableArea => GestureDetector(
        onPanStart: _panStartHandler,
        onPanUpdate: _panUpdateHandler,
        onPanEnd: _panEndHandler,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              _rotatingWheel,
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _screenWidth,
      height: _screenHeight,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: _sideBar,
          ),
          Positioned(top: _screenHeight / 2, right: 0, child: _zoomingWheel),
          Positioned(
            child: _draggableArea,
            top: (_screenHeight - _rotatingWheelDiameter) / 2,
            left: -_rotatingWheelDiameter / 2,
            bottom: 0,
            right: 0,
          )
        ],
      ),
    );
  }
}
