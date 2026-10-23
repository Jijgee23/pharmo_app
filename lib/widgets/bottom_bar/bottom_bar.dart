import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:pharmo_app/application/application.dart';

class BottomBar extends StatefulWidget {
  final List<String> icons;
  final List<String> labels;

  const BottomBar({super.key, required this.icons, required this.labels});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> with SingleTickerProviderStateMixin {
  final _barKey = GlobalKey();
  bool _dragging = false;
  int _dragIndex = 0;
  int _lastDragIndex = -1;

  late AnimationController _bubbleController;
  late Animation<double> _bubbleAnim;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _bubbleAnim = CurvedAnimation(parent: _bubbleController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  int _indexAt(Offset local) {
    final box = _barKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return 0;
    final itemWidth = box.size.width / widget.icons.length;
    return (local.dx / itemWidth).floor().clamp(0, widget.icons.length - 1);
  }

  void _onLongPressStart(LongPressStartDetails d, HomeProvider home) {
    HapticFeedback.mediumImpact();
    setState(() {
      _dragging = true;
      _dragIndex = home.currentIndex;
      _lastDragIndex = home.currentIndex;
    });
    _bubbleController.forward(from: 0);
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails d, HomeProvider home) {
    final idx = _indexAt(d.localPosition);
    if (idx != _lastDragIndex) {
      HapticFeedback.selectionClick();
      setState(() {
        _dragIndex = idx;
        _lastDragIndex = idx;
      });
      home.changeIndex(idx);
    }
  }

  void _onLongPressEnd(HomeProvider home) {
    _bubbleController.reverse().then((_) {
      if (mounted) setState(() => _dragging = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final primary = Theme.of(context).colorScheme.primary;
    final count = widget.icons.length;

    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        final label = widget.labels.length > _dragIndex ? widget.labels[_dragIndex] : '';

        return SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                flex: isPortrait ? 1 : 3,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 6, 20, isPortrait ? 10 : 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Floating drag bubble ─────────────────────────
                      SizeTransition(
                        sizeFactor: _bubbleAnim,
                        axisAlignment: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _DragBubble(
                            icon: widget.icons[_dragIndex],
                            label: label,
                            tabIndex: _dragIndex,
                            tabCount: count,
                            primary: primary,
                          ),
                        ),
                      ),

                      // ── Bar ──────────────────────────────────────────
                      GestureDetector(
                        onLongPressStart: (d) => _onLongPressStart(d, home),
                        onLongPressMoveUpdate: (d) => _onLongPressMoveUpdate(d, home),
                        onLongPressEnd: (_) => _onLongPressEnd(home),
                        onLongPressCancel: () => _onLongPressEnd(home),
                        child: AnimatedScale(
                          scale: _dragging ? 1.03 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: AnimatedContainer(
                                key: _barKey,
                                duration: const Duration(milliseconds: 200),
                                height: isPortrait ? 66 : 50,
                                decoration: BoxDecoration(
                                  color: _dragging
                                      ? primary.withOpacity(0.07)
                                      : Colors.white.withAlpha(parseInt(250 * .08)),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: _dragging
                                        ? primary.withOpacity(0.3)
                                        : Colors.white.withAlpha(parseInt(250 * 0.12)),
                                    width: _dragging ? 1.6 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.09),
                                      blurRadius: 28,
                                      offset: const Offset(0, 6),
                                    ),
                                    BoxShadow(
                                      color: primary.withOpacity(_dragging ? 0.2 : 0.07),
                                      blurRadius: _dragging ? 28 : 16,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: List.generate(count, (i) {
                                    final lbl = widget.labels.length > i ? widget.labels[i] : '';
                                    return _NavItem(
                                      icon: widget.icons[i],
                                      label: lbl,
                                      isSelected: home.currentIndex == i,
                                      showLabel: isPortrait && !_dragging,
                                      isDragTarget: _dragging && _dragIndex == i,
                                      primary: primary,
                                      onTap: () => home.changeIndex(i),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isPortrait) Expanded(child: const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }
}

// ── Floating bubble shown above the bar while dragging ────────────────────────

class _DragBubble extends StatelessWidget {
  final String icon;
  final String label;
  final int tabIndex;
  final int tabCount;
  final Color primary;

  const _DragBubble({
    required this.icon,
    required this.label,
    required this.tabIndex,
    required this.tabCount,
    required this.primary,
  });

  // fraction 0..1, maps to Alignment -1..1
  double get _alignment => tabCount > 1 ? (tabIndex / (tabCount - 1)) * 2 - 1 : 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      alignment: Alignment(_alignment, 0),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.92), primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(icon, width: 32, height: 32, color: Colors.white),
                if (label.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Tail arrow
          CustomPaint(
            size: const Size(14, 8),
            painter: _ArrowPainter(primary),
          ),
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  const _ArrowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}

// ── Nav item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final bool showLabel;
  final bool isDragTarget;
  final Color primary;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.showLabel,
    required this.isDragTarget,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 0,
                vertical: isSelected ? 6 : 0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? primary.withOpacity(isDragTarget ? 0.2 : 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedScale(
                scale: isDragTarget ? 1.18 : (isSelected ? 1.06 : 1.0),
                duration: const Duration(milliseconds: 180),
                child: Image.asset(
                  icon,
                  width: 22,
                  height: 22,
                  color: isSelected ? primary : Colors.black,
                ),
              ),
            ),
            if (showLabel && label.isNotEmpty) ...[
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? primary : Colors.black,
                ),
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
