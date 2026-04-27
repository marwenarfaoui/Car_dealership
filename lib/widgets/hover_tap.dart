import 'package:flutter/material.dart';

class HoverTap extends StatefulWidget {
  const HoverTap({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.hoverScale = 1.02,
    this.hoverColor,
    this.padding,
    this.margin,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final double hoverScale;
  final Color? hoverColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;

  @override
  State<HoverTap> createState() => _HoverTapState();
}

class _HoverTapState extends State<HoverTap> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.hoverColor ?? Colors.white.withOpacity(0.04);
    final scale = _pressed
        ? 0.985
        : _hovering
            ? widget.hoverScale
            : 1.0;

    return MouseRegion(
      cursor: widget.onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) {
        setState(() {
          _hovering = false;
          _pressed = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
        onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
        onTapUp: widget.onTap == null
            ? null
            : (_) {
                setState(() => _pressed = false);
                widget.onTap?.call();
              },
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            margin: widget.margin,
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              color: _hovering ? effectiveColor : Colors.transparent,
            ),
            clipBehavior: widget.clipBehavior,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
