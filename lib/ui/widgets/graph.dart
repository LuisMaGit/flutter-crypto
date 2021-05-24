import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum TypeGraph {
  full,
  preview,
}

class GraphModel {
  String baseText;
  String prefixBigText;
  String bigText;
  List<Plot> plots;
  TypeGraph typeCard;
  GraphModel({
    required this.plots,
    this.baseText = '',
    this.prefixBigText = '',
    this.bigText = '',
    this.typeCard = TypeGraph.full,
  });

  GraphModel copyWith({
    String? baseText,
    String? prefixBigText,
    String? bigText,
    List<Plot>? plots,
    TypeGraph? typeCard,
  }) {
    return GraphModel(
      baseText: baseText ?? this.baseText,
      prefixBigText: prefixBigText ?? this.prefixBigText,
      bigText: bigText ?? this.bigText,
      plots: plots ?? this.plots,
      typeCard: typeCard ?? this.typeCard,
    );
  }
}

class Plot {
  final String x;
  final double y;
  Plot(
    this.x,
    this.y,
  );
}

class _CardModel {
  final double xPosition;
  final double yPosition;
  final String textPrinc;
  final String textSec;
  final double percentageChange;

  _CardModel({
    required this.xPosition,
    required this.yPosition,
    required this.textPrinc,
    required this.textSec,
    required this.percentageChange,
  });
}

class Graph extends LeafRenderObjectWidget {
  final GraphModel graphData;
  final double yMoveFactor;
  final Color primaryColor;
  final Color backGroundColor;
  final Color cardColor;
  final Color bigTextColor;
  final TextStyle? primaryTextStyle;
  final TextStyle? secondaryTextStyle;

  Graph({
    required this.graphData,
    this.yMoveFactor = 0,
    this.primaryColor = Colors.black,
    this.backGroundColor = Colors.white,
    this.cardColor = Colors.white,
    this.bigTextColor = Colors.black,
    this.primaryTextStyle,
    this.secondaryTextStyle,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderGraphBox(
      graphData: graphData,
      yMoveFactor: yMoveFactor,
      primaryColor: primaryColor,
      backGroundColor: backGroundColor,
      cardColor: cardColor,
      primaryTextStyle: primaryTextStyle,
      secondaryTextStyle: secondaryTextStyle,
      bigTextColor: bigTextColor,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderGraphBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..setGraphData = graphData
      ..setYMoveFactor = yMoveFactor
      ..setPrimaryColor = primaryColor
      ..setBackGroundColor = backGroundColor
      ..setCardColor = cardColor
      ..setPrimaryTextStyle = primaryTextStyle
      ..setSecondaryTextStyle = secondaryTextStyle
      ..setBigTextColor = bigTextColor;
  }
}

class RenderGraphBox extends RenderBox {
  RenderGraphBox({
    required GraphModel graphData,
    double yMoveFactor = 0,
    Color primaryColor = Colors.black,
    Color backGroundColor = Colors.white,
    Color cardColor = Colors.white,
    Color bigTextColor = Colors.black,
    TextStyle? primaryTextStyle,
    TextStyle? secondaryTextStyle,
  })  : _graphData = graphData,
        _yMoveFactor = yMoveFactor,
        _backGroundColor = backGroundColor,
        _primaryColor = primaryColor,
        _cardColor = cardColor,
        _primaryTextStyle = primaryTextStyle,
        _secondaryTextStyle = secondaryTextStyle,
        _bigTextColor = bigTextColor;

  //Limits
  late double _height;
  late double _width;
  late double _widthGraph;
  late double _middleY;
  //Props
  GraphModel _graphData;
  double _yMoveFactor;
  Color _primaryColor;
  Color _backGroundColor;
  Color _cardColor;
  Color _bigTextColor;
  TextStyle? _primaryTextStyle;
  TextStyle? _secondaryTextStyle;
  //Control var
  int _currentCardIdx = -1;
  //Paints
  late Paint _linePaint;
  late Paint _gradientPaint;
  //Points
  List<double> _initialXPoints = [];
  List<double> _finalYPoints = [];
  //LateralMarks (Points, yOffsets)
  List<double> _lateralMarks = [];
  List<double> _lateralMarksOffsets = [];
  //Cards
  List<_CardModel> _cards = [];
  //Const
  static const double _curveW = 3;
  static const double _paddingVerticalCard = 10;
  static const double _breakTextCard = 5;
  static const double _paddingHorizontalCard = 15;
  static const double _totalHeightPadding =
      3 * _paddingVerticalCard + _breakTextCard;
  static const double _totalWidhtPadding =
      2 * _paddingHorizontalCard; //2*(_paddingCard)
  static const double _radiusCard = 14;
  static const double _lateralMarksWidth = 50;
  //Gestures
  late HorizontalDragGestureRecognizer _drag;
  late TapGestureRecognizer _tap;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    //Drag
    _drag = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onUpdate = (DragUpdateDetails details) {
        _horizontalDragHandler(details.localPosition);
      };
    _tap = TapGestureRecognizer(debugOwner: this)
      ..onTapDown = (TapDownDetails details) {
        _horizontalDragHandler(details.localPosition);
      };
  }

  @override
  void detach() {
    super.detach();
    _drag.dispose();
  }

  @override
  void performLayout() {
    size = Size(constraints.maxWidth, constraints.maxHeight);
    _height = size.height;
    _width = size.width;
    _widthGraph = _width;
    if (_graphData.typeCard == TypeGraph.full) {
      _widthGraph -= _lateralMarksWidth;
    }
    _middleY = _height / 2;

    //Needs dimensions
    if (_graphData.typeCard == TypeGraph.full) _prepareGradientBrush();
    _prepareLineBrush();
  }

  @override
  bool hitTestSelf(Offset position) {
    return size.contains(position);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));

    if (event is PointerDownEvent && _graphData.typeCard == TypeGraph.full) {
      _drag.addPointer(event);
      _tap.addPointer(event);
    }
  }

  //Events
  set setGraphData(GraphModel value) {
    bool newPlots = false;
    bool newPrefixBigText = false;
    bool forceBigText = false;
    bool newbaseText = false;
    bool newTypeCard = false;

    if (value.plots.length != _graphData.plots.length) {
      newPlots = true;
    }

    if (!newPlots) {
      for (int x = 0; x < value.plots.length; x++) {
        if (value.plots[x].y != _graphData.plots[x].y) {
          newPlots = true;
          break;
        }
      }
    }

    if (newPlots == true) {
      _graphData.plots.clear();
      _graphData.plots = value.plots;
      _initialXPoints = [];
    }

    if (_graphData.prefixBigText != value.prefixBigText) {
      _graphData.prefixBigText = value.prefixBigText;
      newPrefixBigText = true;
    }

    if (_graphData.baseText != value.baseText) {
      _graphData.baseText = value.baseText;
      newbaseText = true;
    }

    if (_graphData.typeCard != value.typeCard) {
      _graphData.typeCard = value.typeCard;
      newTypeCard = true;
    }

    if (newTypeCard) {
      _initialXPoints = [];
    }

    if (_graphData.bigText != value.bigText) {
      _graphData.bigText = value.bigText;
      forceBigText = true;
    }

    if (newPlots ||
        newPrefixBigText ||
        newbaseText ||
        newTypeCard ||
        forceBigText) {
      markNeedsPaint();
    }
  }

  set setYMoveFactor(double value) {
    if (_yMoveFactor == value) return;
    _yMoveFactor = value;
    markNeedsPaint();
  }

  set setPrimaryTextStyle(TextStyle? value) {
    if (value == _primaryTextStyle) return;

    _primaryTextStyle = value;
    markNeedsPaint();
  }

  set setSecondaryTextStyle(TextStyle? value) {
    if (value == _secondaryTextStyle) return;

    _secondaryTextStyle = value;
    markNeedsPaint();
  }

  set setBackGroundColor(Color value) {
    if (value == _backGroundColor) return;

    _backGroundColor = value;
    markNeedsPaint();
  }

  set setBigTextColor(Color value) {
    if (value == _bigTextColor) return;

    _bigTextColor = value;
    markNeedsPaint();
  }

  set setPrimaryColor(Color value) {
    if (_primaryColor == value) return;

    _primaryColor = value;
    markNeedsPaint();
  }

  set setCardColor(Color value) {
    if (_cardColor == value) return;

    _cardColor = value;
    markNeedsPaint();
  }

  void _horizontalDragHandler(Offset localPosition) {
    if (localPosition.dx > _widthGraph) return;

    if (_yMoveFactor == 1) {
      final rawPositon =
          (localPosition.dx / _widthGraph) * _graphData.plots.length;

      final currentCardIdx = int.parse(rawPositon.toStringAsFixed(0));

      if (currentCardIdx != _currentCardIdx &&
          currentCardIdx >= 0 &&
          currentCardIdx < _graphData.plots.length) {
        _currentCardIdx = currentCardIdx;
        markNeedsPaint();
        markNeedsSemanticsUpdate();
      }
    }
  }

  //Methods
  void _setUpValues() {
    //Reset
    _initialXPoints = [];
    _finalYPoints = [];
    _cards = [];
    _currentCardIdx = -1;

    //Min, Max
    double minYPlot = _graphData.plots[0].y;
    double maxYPlot = _graphData.plots[0].y;
    _graphData.plots.forEach((p) {
      minYPlot = min(minYPlot, p.y);
      maxYPlot = max(maxYPlot, p.y);
    });
    final dy = maxYPlot - minYPlot;
    //Plot Points
    for (int p = 0; p < _graphData.plots.length; p++) {
      final x = _widthGraph * p / (_graphData.plots.length - 1);
      final y = (_height / dy) * (maxYPlot - _graphData.plots[p].y);
      _initialXPoints.add(x);
      _finalYPoints.add(y);

      double percentageChange = 0;
      if (p != 0) {
        percentageChange = _getPercentageChange(
          _graphData.plots[p - 1].y,
          _graphData.plots[p].y,
        );
      }

      _cards.add(
        _CardModel(
          xPosition: _initialXPoints[p],
          yPosition: _finalYPoints[p],
          textPrinc: _graphData.plots[p].y.toStringAsFixed(2),
          textSec: _graphData.plots[p].x,
          percentageChange: percentageChange,
        ),
      );
    }

    //LateralMarsks Points
    final stepMark = dy / 4;
    final stepOffsetMark = _height / 4;
    double baseMark = maxYPlot;
    double baseOffsetMark = 0;
    _lateralMarks = [];
    _lateralMarksOffsets = [];
    for (int x = 0; x < 5; x++) {
      if (x == 0) {
        _lateralMarks.add(maxYPlot);
        _lateralMarksOffsets.add(0);
      }
      if (x == 4) {
        _lateralMarks.add(minYPlot);
        _lateralMarksOffsets.add(_height);
      }

      if (x > 0 && x < 4) {
        baseMark -= stepMark;
        baseOffsetMark += stepOffsetMark;
        _lateralMarks.add(baseMark);
        _lateralMarksOffsets.add(baseOffsetMark);
      }
    }
  }

  double _getPercentageChange(double first, double second) {
    final percentage = (second / first) * (first > second ? -1 : 1);
    return percentage;
  }

  void _prepareGradientBrush() {
    _gradientPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(_widthGraph / 2, 0),
        Offset(_widthGraph / 2, _height),
        [
          _primaryColor.withOpacity(.5),
          _backGroundColor.withOpacity(.1),
          _backGroundColor,
        ],
        [0, 1, 1],
      );
  }

  void _prepareLineBrush() {
    _linePaint = Paint()
      ..color = _primaryColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = _curveW;
  }

  double _getdy(int x) {
    return (_finalYPoints[x] - _middleY) * _yMoveFactor + _middleY;
  }

  void _drawLine(Canvas canvas) {
    final endPoint = _height / 2;
    final path = Path()
      ..moveTo(0, endPoint)
      ..lineTo(_widthGraph, _height / 2)
      ..lineTo(_widthGraph, _height)
      ..lineTo(0, _height)
      ..close();

    if (_graphData.typeCard == TypeGraph.full)
      canvas.drawPath(path, _gradientPaint);

    canvas.drawLine(
      Offset(0, endPoint),
      Offset(_widthGraph, endPoint),
      _linePaint,
    );
  }

  void _drawGraph(Canvas canvas) {
    for (int x = 0; x < _finalYPoints.length - 1; x++) {
      double dy = _getdy(x);
      double dy1 = _getdy(x + 1);

      canvas.drawLine(Offset(_initialXPoints[x], dy),
          Offset(_initialXPoints[x + 1], dy1), _linePaint);
    }
  }

  void _drawCard(Canvas canvas, _CardModel model) {
    final textMaxW = _widthGraph / 3;
    double widhtCard = 0;
    //Text Principal
    final TextPainter textPrinc = TextPainter(
        text: TextSpan(
            text: '${_graphData.prefixBigText} ${model.textPrinc}',
            style: _primaryTextStyle?.copyWith(fontSize: 16)),
        maxLines: 1,
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr)
      ..layout(
        maxWidth: textMaxW,
      );
    widhtCard = max(widhtCard, textPrinc.width);
    //Second Text
    final TextPainter textSecondary = TextPainter(
        text: TextSpan(
            text: model.textSec,
            style: _secondaryTextStyle?.copyWith(fontSize: 14)),
        maxLines: 2,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: textMaxW);
    widhtCard = max(widhtCard, textSecondary.width);
    //Third Text
    bool grow = model.percentageChange > 0;
    String arrow = grow ? '↑' : '↓';
    final TextPainter textThird = TextPainter(
        text: TextSpan(
            text: model.percentageChange != 0
                ? '$arrow${model.percentageChange.toStringAsFixed(3)}%'
                : '',
            style: _secondaryTextStyle?.copyWith(
              fontSize: 14,
              color: grow ? Colors.greenAccent : Colors.redAccent,
            )),
        textAlign: TextAlign.left,
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(
        maxWidth: textMaxW,
      );

    //Width Card (Max Text)
    widhtCard = max(widhtCard, textThird.width);
    widhtCard += _totalWidhtPadding;
    //Height Text + padding
    final heightCard = textPrinc.height +
        textSecondary.height +
        textThird.height +
        _totalHeightPadding;

    final drawToRight = model.xPosition + widhtCard < _widthGraph;
    final drawDown = model.yPosition + heightCard < _height;

    double startX = model.xPosition;
    double startY = model.yPosition;
    double finalX = startX, finalY = startY;

    //Mark
    final paintOut = Paint()..color = _cardColor;
    final paintIn = Paint()..color = _primaryColor;
    final rectShadowMark =
        Rect.fromCenter(center: Offset(startX, startY), width: 14, height: 14);
    final rRectShadowMark = RRect.fromRectXY(rectShadowMark, 12, 12);
    final pathShadowMark = Path()..addRRect(rRectShadowMark);
    canvas.drawShadow(pathShadowMark, _primaryColor.withOpacity(.5), 2, true);
    canvas.drawCircle(Offset(startX, startY), 6, paintOut);
    canvas.drawCircle(Offset(startX, startY), 3, paintIn);

    if (drawToRight) {
      finalX += widhtCard;
    } else {
      startX -= widhtCard;
      finalX = startX + widhtCard;
    }

    if (drawDown) {
      finalY += heightCard;
    } else {
      startY -= heightCard;
      finalY = startY + heightCard;
    }

    // Container
    final container = Paint()..color = _cardColor;
    final rect = Rect.fromPoints(
      Offset(startX, startY),
      Offset(finalX, finalY),
    );
    final rRect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(_radiusCard),
      topRight: Radius.circular(_radiusCard),
      bottomLeft: Radius.circular(_radiusCard),
      bottomRight: Radius.circular(_radiusCard),
    );

    final shadowPath = Path()..addRRect(rRect);
    canvas.drawShadow(shadowPath, _cardColor.withOpacity(.5), 2, true);
    canvas.drawRRect(rRect, container);

    //Text
    textPrinc.paint(canvas,
        Offset(startX + _paddingHorizontalCard, startY + _paddingVerticalCard));
    textSecondary.paint(
        canvas,
        Offset(
          startX + _paddingHorizontalCard,
          startY + textPrinc.height + 2 * _paddingVerticalCard,
        ));
    textThird.paint(
        canvas,
        Offset(
          startX + _paddingHorizontalCard,
          startY +
              textPrinc.height +
              textSecondary.height +
              2 * _paddingVerticalCard +
              _breakTextCard,
        ));
  }

  void _drawGradinte(Canvas canvas) {
    final path = Path()..moveTo(_initialXPoints[0], _middleY);

    for (int x = 0; x < _finalYPoints.length - 1; x++) {
      double dy = _getdy(x);
      double dy1 = _getdy(x + 1);
      if (x == 0) {
        path.moveTo(_initialXPoints[x], dy);
        path.lineTo(_initialXPoints[x + 1], dy1);
      } else {
        path.lineTo(_initialXPoints[x + 1], dy1);
      }
      if (x == _finalYPoints.length - 2) {
        path.lineTo(_widthGraph, _height);
        path.lineTo(0, _height);
        canvas.drawPath(path, _gradientPaint);
      }
    }
  }

  void _drawBackSign(Canvas canvas) {
    final textBackSecondary = TextPainter(
        text: TextSpan(
          text: _graphData.plots.isEmpty ? '' : _graphData.baseText,
          style: _secondaryTextStyle?.copyWith(fontSize: 16),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr)
      ..layout(
        maxWidth: _widthGraph - 2 * _paddingHorizontalCard,
      );

    final textBackPrimary = TextPainter(
        text: TextSpan(
          text: _graphData.bigText.isEmpty
              ? '${_graphData.prefixBigText} ${_graphData.plots.last.y.toStringAsFixed(2)}'
              : '${_graphData.bigText}',
          style: _primaryTextStyle?.copyWith(color: _bigTextColor),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr)
      ..layout(
        maxWidth: _widthGraph - 2 * _paddingHorizontalCard,
      );

    textBackPrimary.paint(
        canvas, Offset(_paddingHorizontalCard, textBackSecondary.height + 5));
    textBackSecondary.paint(canvas, Offset(_paddingHorizontalCard, 0));
  }

  void _drawLateralMarks(Canvas canvas) {
    final offsetText = _widthGraph + 5;

    for (int x = 0; x < 5; x++) {
      final text = TextPainter(
          text: TextSpan(
            text: _lateralMarks[x].toStringAsFixed(2),
            style: _secondaryTextStyle?.copyWith(fontSize: 10),
          ),
          maxLines: 2,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr)
        ..layout(
          maxWidth: 45,
        );

      text.paint(
          canvas,
          Offset(
              offsetText,
              x != 0
                  ? _lateralMarksOffsets[x] - text.height
                  : _lateralMarksOffsets[x]));
    }
  }

  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    //Brushes
    _prepareLineBrush();
    if (_graphData.typeCard == TypeGraph.full) _prepareGradientBrush();

    //Line with back sign
    if (_graphData.plots.isEmpty) {
      _drawLine(canvas);
      //Back Sign
      if (_graphData.typeCard == TypeGraph.full) _drawBackSign(canvas);
      canvas.restore();
      return;
    }
    //SetUp
    if (_initialXPoints.isEmpty) {
      _setUpValues();
    }
    //Back Sign
    if (_graphData.typeCard == TypeGraph.full) _drawBackSign(canvas);
    //Gradient
    if (_graphData.typeCard == TypeGraph.full) _drawGradinte(canvas);
    //Graph
    _drawGraph(canvas);
    //Draw Lateral Marks
    if (_graphData.typeCard == TypeGraph.full && _yMoveFactor > 0) {
      _drawLateralMarks(canvas);
    }
    //Card
    if (_currentCardIdx != -1 &&
        _yMoveFactor == 1 &&
        _graphData.typeCard != TypeGraph.preview) {
      _drawCard(canvas, _cards[_currentCardIdx]);
    }

    canvas.restore();
  }
}
