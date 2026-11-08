import 'package:flutter/material.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/widgets/ui.dart';

/// Horizontal stepper like the reference design (done = black check, current = black ring, pending = grey)
class HStepper extends StatelessWidget {
  final List<String> steps;
  final int current; // index of current step; all before are done
  final bool dark, showLabels;
  const HStepper({super.key, required this.steps, required this.current, this.dark = false, this.showLabels = true});
  @override
  Widget build(BuildContext context) {
    final on = dark ? Colors.white : C.black;
    final off = dark ? Colors.white30 : C.grey;
    final row = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      if (i > 0) row.add(Expanded(child: Container(height: i <= current ? 3 : 1.5, color: i <= current ? on : off)));
      final done = i < current, cur = i == current;
      row.add(Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: done ? on : (cur ? Colors.transparent : off),
          shape: BoxShape.circle,
          border: cur ? Border.all(color: on, width: 3) : null,
        ),
        child: done ? Icon(Icons.check, size: 16, color: dark ? C.black : Colors.white) : null,
      ));
    }
    return Column(children: [
      Row(children: row),
      if (showLabels) ...[
        gap8,
        Row(children: [
          for (var i = 0; i < steps.length; i++)
            Expanded(
                child: Text(steps[i],
                    textAlign: i == 0 ? TextAlign.start : (i == steps.length - 1 ? TextAlign.end : TextAlign.center),
                    style: ts(10.5, w: i == current ? FontWeight.w700 : FontWeight.w500, c: dark ? Colors.white70 : C.muted))),
        ]),
      ],
    ]);
  }
}

class TItem {
  final String title, sub;
  final int state; // 0 pending, 1 current, 2 done
  final Widget? trailing;
  const TItem(this.title, this.sub, this.state, {this.trailing});
}

/// CMP-03 vertical timeline (dotted line like the reference bottom sheet)
class VTimeline extends StatelessWidget {
  final List<TItem> items;
  const VTimeline(this.items, {super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
        for (var i = 0; i < items.length; i++)
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 28,
                child: Column(children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: items[i].state == 2 ? C.black : (items[i].state == 1 ? Colors.white : C.grey),
                      shape: BoxShape.circle,
                      border: items[i].state == 1 ? Border.all(color: C.black, width: 3) : null,
                    ),
                    child: items[i].state == 2 ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
                  ),
                  if (i < items.length - 1) Expanded(child: CustomPaint(painter: _Dash(), child: const SizedBox(width: 2))),
                ]),
              ),
              gap12,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(items[i].title, style: ts(14, w: items[i].state == 1 ? FontWeight.w800 : FontWeight.w600)),
                        if (items[i].sub.isNotEmpty) Text(items[i].sub, style: ts(12, c: C.muted)),
                      ]),
                    ),
                    if (items[i].trailing != null) items[i].trailing!,
                  ]),
                ),
              ),
            ]),
          ),
      ]);
}

class _Dash extends CustomPainter {
  @override
  void paint(Canvas c, Size z) {
    final p = Paint()..color = C.grey..strokeWidth = 2;
    for (double y = 2; y < z.height - 2; y += 7) {
      c.drawLine(Offset(z.width / 2, y), Offset(z.width / 2, y + 3), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
