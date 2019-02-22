library bubble_bottom_bar;

import 'dart:collection' show Queue;
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

const double _kActiveFontSize = 14.0;
const double _kBottomMargin = 8.0;

class BubbleBottomBar extends StatefulWidget {
  BubbleBottomBar({
    Key key,
    @required this.items,
    this.onTap,
    this.currentIndex = 0,
    this.fixedColor,
    @required this.opacity,
    this.iconSize = 24.0,
    this.borderRadius,
  })  : assert(items != null),
        assert(items.length >= 2),
        assert(
            items.every((BubbleBottomBarItem item) => item.title != null) ==
                true,
            'Every item must have a non-null title',),
        assert(0 <= currentIndex && currentIndex < items.length),
        assert(iconSize != null),
        super(key: key);

  final List<BubbleBottomBarItem> items;
  final ValueChanged<int> onTap; //stream ? or listener ? callbacks dude
  final int currentIndex;
  final Color fixedColor;
  final double iconSize;
  final double opacity;
  final double borderRadius;

  @override
  _BottomNavigationBarState createState() => _BottomNavigationBarState();
}

class _BottomNavigationTile extends StatelessWidget {
  const _BottomNavigationTile(
    this.item,
    this.opacity,
    this.animation,
    this.iconSize, {
    this.onTap,
    this.colorTween,
    this.flex,
    this.selected = false,
    this.indexLabel,
  }) : assert(selected != null);

  final BubbleBottomBarItem item;
  final Animation<double> animation;
  final double iconSize;
  final VoidCallback onTap;
  final ColorTween colorTween;
  final double flex;
  final bool selected;
  final String indexLabel;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    int size;
    Widget label;

    size = (flex * 1000.0).round();
    label = _Label(
        animation: animation, item: item, color: item.backgroundColor);

    return Expanded(
      flex: size,
      child: Semantics(
        container: true,
        header: true,
        selected: selected,
        child: Stack(
          children: <Widget>[
            InkResponse(
              onTap: onTap,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                    color: selected
                        ? item.backgroundColor.withOpacity(opacity)
                        : Colors.transparent,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(50),
                      left: Radius.circular(50),
                    )),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: selected
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    _TileIcon(
                      colorTween: colorTween,
                      animation: animation,
                      iconSize: iconSize,
                      selected: selected,
                      item: item,
                    ),
                    selected ? label : Container(),
                  ],
                ),
              ),
            ),
            Semantics(
              label: indexLabel,
            )
          ],
        ),
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({
    Key key,
    @required this.colorTween,
    @required this.animation,
    @required this.iconSize,
    @required this.selected,
    @required this.item,
  }) : super(key: key);

  final ColorTween colorTween;
  final Animation<double> animation;
  final double iconSize;
  final bool selected;
  final BubbleBottomBarItem item;

  @override
  Widget build(BuildContext context) {
    double tweenStart;
    Color iconColor;
    tweenStart = 0;
    iconColor = Colors.white;
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1.0,
      child: Container(
        margin: EdgeInsets.only(
          top: Tween<double>(
            begin: tweenStart,
            end: 0,
          ).evaluate(animation),
        ),
        child: IconTheme(
          data: IconThemeData(
            color: selected ? item.backgroundColor : iconColor,
            size: iconSize,
          ),
          child: selected ? item.activeIcon : item.icon,
        ),
      ),
    );
  }
}


class _Label extends StatelessWidget {
  _Label({
    Key key,
    @required this.animation,
    @required this.item,
    @required this.color,
  }) : super(key: key);

  Animation<double> animation;
  BubbleBottomBarItem item;
  Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      heightFactor: 1.0,
      child: Container(
        margin: EdgeInsets.only(
          bottom: Tween<double>(
            begin: 0,
            end: 0,
          ).evaluate(animation),
        ),
        child: FadeTransition(
          alwaysIncludeSemantics: true,
          opacity: animation,
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: _kActiveFontSize,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            child: item.title,
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationBarState extends State<BubbleBottomBar>
    with TickerProviderStateMixin {
  List<AnimationController> _controllers = <AnimationController>[];
  List<CurvedAnimation> _animations;
  final Queue<_Circle> _circles = Queue<_Circle>();
  Color _backgroundColor;

  static final Animatable<double> _flexTween =
      Tween<double>(begin: 1.0, end: 1.5);

  void _resetState() {
    for (AnimationController controller in _controllers) controller.dispose();
    for (_Circle circle in _circles) circle.dispose();
    _circles.clear();

    _controllers =
        List<AnimationController>.generate(widget.items.length, (int index) {
      return AnimationController(
        duration: kThemeAnimationDuration,
        vsync: this,
      )..addListener(_rebuild);
    });
    _animations =
        List<CurvedAnimation>.generate(widget.items.length, (int index) {
      return CurvedAnimation(
        parent: _controllers[index],
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn.flipped,
      );
    });
    _controllers[widget.currentIndex].value = 1.0;
    _backgroundColor = widget.items[widget.currentIndex].backgroundColor;
  }

  @override
  void initState() {
    super.initState();
    _resetState();
  }

  void _rebuild() {
    setState(() {
    });
  }

  @override
  void dispose() {
    for (AnimationController controller in _controllers) controller.dispose();
    for (_Circle circle in _circles) circle.dispose();
    super.dispose();
  }

  double _evaluateFlex(Animation<double> animation) =>
      _flexTween.evaluate(animation);

  @override
  void didUpdateWidget(BubbleBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items.length != oldWidget.items.length) {
      _resetState();
      return;
    }

    if (widget.currentIndex != oldWidget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    } else {
      if (_backgroundColor != widget.items[widget.currentIndex].backgroundColor)
        _backgroundColor = widget.items[widget.currentIndex].backgroundColor;
    }
  }

  List<Widget> _createTiles() {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    assert(localizations != null);
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < widget.items.length; i += 1) {
      children.add(
        _BottomNavigationTile(
          widget.items[i],
          widget.opacity,
          _animations[i],
          widget.iconSize,
          onTap: () {
            if (widget.onTap != null) widget.onTap(i);
          },
          flex: _evaluateFlex(_animations[i]),
          selected: i == widget.currentIndex,
          indexLabel: localizations.tabLabel(
              tabIndex: i + 1, tabCount: widget.items.length),
        ),
      );
    }
    return children;
  }

  Widget _createContainer(List<Widget> tiles) {
    return DefaultTextStyle.merge(
      overflow: TextOverflow.ellipsis,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tiles,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasMaterialLocalizations(context));

    final double additionalBottomPadding =
        math.max(MediaQuery.of(context).padding.bottom - _kBottomMargin, 0.0);
    return Semantics(
      explicitChildNodes: true,
      child: Material(
          color: Colors.white,
          borderRadius: widget.borderRadius == null ? null : BorderRadius.vertical(
            top: Radius.circular(widget.borderRadius),
          ),
          elevation: 8.0,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight:
                      kBottomNavigationBarHeight + additionalBottomPadding),
              child: CustomPaint(
                painter: _RadialPainter(
                  circles: _circles.toList(),
                  textDirection: Directionality.of(context),
                ),
                child: Material(
                  // Splashes.
                  type: MaterialType.transparency,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: additionalBottomPadding),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      child: _createContainer(_createTiles()),
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}

class _Circle {
  _Circle({
    @required this.state,
    @required this.index,
    @required this.color,
    @required TickerProvider vsync,
  })  : assert(state != null),
        assert(index != null),
        assert(color != null) {
    controller = AnimationController(
      duration: kThemeAnimationDuration,
      vsync: vsync,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
    controller.forward();
  }

  final _BottomNavigationBarState state;
  final int index;
  final Color color;
  AnimationController controller;
  CurvedAnimation animation;

  double get horizontalLeadingOffset {
    double weightSum(Iterable<Animation<double>> animations) {
      return animations
          .map<double>(state._evaluateFlex)
          .fold<double>(0.0, (double sum, double value) => sum + value);
    }

    final double allWeights = weightSum(state._animations);
    final double leadingWeights =
        weightSum(state._animations.sublist(0, index));

    return (leadingWeights +
            state._evaluateFlex(state._animations[index]) / 2.0) /
        allWeights;
  }

  void dispose() {
    controller.dispose();
  }
}

class _RadialPainter extends CustomPainter {
  _RadialPainter({
    @required this.circles,
    @required this.textDirection,
  })  : assert(circles != null),
        assert(textDirection != null);

  final List<_Circle> circles;
  final TextDirection textDirection;

  static double _maxRadius(Offset center, Size size) {
    final double maxX = math.max(center.dx, size.width - center.dx);
    final double maxY = math.max(center.dy, size.height - center.dy);
    return math.sqrt(maxX * maxX + maxY * maxY);
  }

  @override
  bool shouldRepaint(_RadialPainter oldPainter) {
    if (textDirection != oldPainter.textDirection) return true;
    if (circles == oldPainter.circles) return false;
    if (circles.length != oldPainter.circles.length) return true;
    for (int i = 0; i < circles.length; i += 1)
      if (circles[i] != oldPainter.circles[i]) return true;
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (_Circle circle in circles) {
      final Paint paint = Paint()..color = circle.color;
      final Rect rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
      canvas.clipRect(rect);
      double leftFraction;
      switch (textDirection) {
        case TextDirection.rtl:
          leftFraction = 1.0 - circle.horizontalLeadingOffset;
          break;
        case TextDirection.ltr:
          leftFraction = circle.horizontalLeadingOffset;
          break;
      }
      final Offset center =
          Offset(leftFraction * size.width, size.height / 2.0);
      final Tween<double> radiusTween = Tween<double>(
        begin: 0.0,
        end: _maxRadius(center, size),
      );
      canvas.drawCircle(
        center,
        radiusTween.transform(circle.animation.value),
        paint,
      );
    }
  }
}

class BubbleBottomBarItem {
  const BubbleBottomBarItem({
    @required this.icon,
    this.title,
    Widget activeIcon,
    this.backgroundColor,
  }) : activeIcon = activeIcon ?? icon,
        assert(icon != null);
  final Widget icon;
  final Widget activeIcon;
  final Widget title;
  final Color backgroundColor;
}