import 'package:flutter/material.dart';

/// Animation count-up pour les KPIs du dashboard.
/// Anime une valeur de 0 a [end] avec une courbe easeOut.
class AnimatedCountUp extends StatefulWidget {
  final double end;
  final String prefix;
  final String suffix;
  final int decimals;
  final Duration duration;
  final TextStyle? style;
  final Curve curve;

  const AnimatedCountUp({
    super.key,
    required this.end,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    this.duration = const Duration(milliseconds: 1500),
    this.style,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedCountUp> createState() => _AnimatedCountUpState();
}

class _AnimatedCountUpState extends State<AnimatedCountUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0, end: widget.end).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.end,
      ).animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value.toStringAsFixed(widget.decimals);
        return Text(
          '${widget.prefix}$value${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
