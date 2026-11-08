import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/widgets/ui.dart';

class Series {
  final List<double> v;
  final Color color;
  final bool fill, dashed;
  const Series(this.v, {this.color = C.black, this.fill = false, this.dashed = false});
}

/// CMP-12 TimeSeriesChart (line / area)
class LineChart extends StatelessWidget {
  final List<Series> series;
  final List<String> labels;
  final double height;
  final bool dark;
  const LineChart({super.key, required this.series, this.labels = const [], this.height = 150, this.dark = false});
  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(height: height, width: double.infinity, child: CustomPaint(painter: _LinePainter(series, dark))),
        if (labels.isNotEmpty) ...[
          gap8,
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (final l in labels) Text(l, style: ts(11, c: dark ? Colors.white54 : C.muted)),
            ]),
          ),
        ],
      ]);
}

class _LinePainter extends CustomPainter {
  final List<Series> s;
  final bool dark;
  _LinePainter(this.s, this.dark);
  @override
  void paint(Canvas c, Size z) {
    final grid = Paint()..color = dark ? Colors.white12 : C.line..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = z.height * i / 3;
      c.drawLine(Offset(0, y), Offset(z.width, y), grid);
    }
    for (final se in s) {
      if (se.v.length < 2) continue;
      final mx = se.v.reduce(math.max) * 1.15;
      final pts = <Offset>[];
      for (var i = 0; i < se.v.length; i++) {
        pts.add(Offset(z.width * i / (se.v.length - 1), z.height - (mx == 0 ? 0 : se.v[i] / mx) * z.height));
      }
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length; i++) {
        final p0 = pts[i - 1], p1 = pts[i];
        final cx = (p0.dx + p1.dx) / 2;
        path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
      }
      if (se.fill) {
        final area = Path.from(path)..lineTo(z.width, z.height)..lineTo(0, z.height)..close();
        c.drawPath(area, Paint()
          ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [se.color.withOpacity(.35), se.color.withOpacity(.02)])
              .createShader(Offset.zero & z));
      }
      final pen = Paint()..color = se.color..strokeWidth = 2.4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
      if (se.dashed) {
        for (final m in path.computeMetrics()) {
          var d = 0.0;
          while (d < m.length) {
            c.drawPath(m.extractPath(d, math.min(d + 6, m.length)), pen);
            d += 11;
          }
        }
      } else {
        c.drawPath(path, pen);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter o) => o.s != s;
}

/// grouped bar chart; groups[i] = values of group i
class BarChart extends StatelessWidget {
  final List<List<double>> groups;
  final List<Color> colors;
  final List<String> labels;
  final double height;
  final bool dark;
  const BarChart({super.key, required this.groups, this.colors = const [C.black], this.labels = const [], this.height = 140, this.dark = false});
  @override
  Widget build(BuildContext context) {
    double mx = 0;
    for (final g in groups) {
      for (final v in g) {
        mx = math.max(mx, v);
      }
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(children: [
        SizedBox(
          height: height,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (final g in groups)
              Expanded(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (var j = 0; j < g.length; j++)
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        constraints: const BoxConstraints(maxWidth: 16),
                        height: mx == 0 ? 0 : height * g[j] / mx,
                        decoration: BoxDecoration(color: colors[j % colors.length], borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                ]),
              ),
          ]),
        ),
        if (labels.isNotEmpty) ...[
          gap8,
          Row(children: [for (final l in labels) Expanded(child: Text(l, textAlign: TextAlign.center, style: ts(11, c: dark ? Colors.white54 : C.muted)))]),
        ],
      ]),
    );
  }
}

class Legend extends StatelessWidget {
  final List<(String, Color)> items;
  final bool dark;
  const Legend(this.items, {super.key, this.dark = false});
  @override
  Widget build(BuildContext context) => Wrap(spacing: 16, runSpacing: 6, children: [
        for (final i in items)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: i.$2, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(i.$1, style: ts(12, c: dark ? Colors.white70 : C.muted)),
          ]),
      ]);
}

/// CMP-02 DSCRGauge (semicircle)
class Gauge extends StatelessWidget {
  final double value; // 0..1.2
  final String center, caption;
  final bool dark;
  const Gauge({super.key, required this.value, required this.center, required this.caption, this.dark = false});
  @override
  Widget build(BuildContext context) {
    final color = value >= 1 ? C.green : (value >= .7 ? C.amber : C.red);
    return SizedBox(
      height: 120,
      width: 220,
      child: CustomPaint(
        painter: _GaugePainter(value.clamp(0, 1).toDouble(), color, dark),
        child: Align(
          alignment: const Alignment(0, .7),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(center, style: ts(28, w: FontWeight.w800, c: dark ? Colors.white : C.ink)),
            Text(caption, style: ts(12, c: dark ? Colors.white60 : C.muted)),
          ]),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double v;
  final Color color;
  final bool dark;
  _GaugePainter(this.v, this.color, this.dark);
  @override
  void paint(Canvas c, Size z) {
    final r = Rect.fromCircle(center: Offset(z.width / 2, z.height), radius: z.width / 2 - 12);
    final bg = Paint()..color = dark ? Colors.white24 : C.line..strokeWidth = 14..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final fg = Paint()..color = color..strokeWidth = 14..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    c.drawArc(r, math.pi, math.pi, false, bg);
    c.drawArc(r, math.pi, math.pi * v, false, fg);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter o) => o.v != v;
}

class Donut extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final String center;
  final double size;
  final bool dark;
  const Donut({super.key, required this.values, required this.colors, this.center = '', this.size = 120, this.dark = false});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _DonutPainter(values, colors, dark),
          child: Center(child: Text(center, style: ts(size * .16, w: FontWeight.w800, c: dark ? Colors.white : C.ink))),
        ),
      );
}

class _DonutPainter extends CustomPainter {
  final List<double> v;
  final List<Color> c;
  final bool dark;
  _DonutPainter(this.v, this.c, this.dark);
  @override
  void paint(Canvas canvas, Size z) {
    final total = v.fold<double>(0, (a, b) => a + b);
    final r = Rect.fromLTWH(10, 10, z.width - 20, z.height - 20);
    canvas.drawArc(r, 0, math.pi * 2, false, Paint()..color = dark ? Colors.white12 : C.line..strokeWidth = 16..style = PaintingStyle.stroke);
    var start = -math.pi / 2;
    for (var i = 0; i < v.length; i++) {
      final sw = total == 0 ? 0.0 : math.pi * 2 * v[i] / total;
      canvas.drawArc(r, start, sw, false, Paint()..color = c[i % c.length]..strokeWidth = 16..style = PaintingStyle.stroke);
      start += sw;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter o) => o.v != v;
}

class Bar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final bool dark;
  const Bar(this.value, {super.key, this.color = C.black, this.dark = false});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(R.pill),
        child: LinearProgressIndicator(
            value: value.clamp(0, 1).toDouble(), minHeight: 6, color: color, backgroundColor: dark ? Colors.white24 : C.grey),
      );
}
