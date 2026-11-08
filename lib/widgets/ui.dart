import 'package:flutter/material.dart';
import 'package:ecosolar/core/theme.dart';

const gap8 = SizedBox(height: 8, width: 8);
const gap12 = SizedBox(height: 12, width: 12);
const gap16 = SizedBox(height: 16, width: 16);
const gap24 = SizedBox(height: 24, width: 24);

TextStyle ts(double size, {FontWeight w = FontWeight.w500, Color c = C.ink}) =>
    TextStyle(fontSize: size, fontWeight: w, color: c, height: 1.5);

/// Card with soft grey-blue fill (default) or black hero style
class ECard extends StatelessWidget {
  final Widget child;
  final bool dark;
  final Color? color;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Border? border;
  const ECard({super.key, required this.child, this.dark = false, this.color, this.padding = const EdgeInsets.all(20), this.onTap, this.border});
  @override
  Widget build(BuildContext context) {
    final bg = color ?? (dark ? C.black : C.soft);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(dark ? R.hero : R.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(dark ? R.hero : R.card),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: border == null ? null : BoxDecoration(border: border, borderRadius: BorderRadius.circular(dark ? R.hero : R.card)),
          child: DefaultTextStyle.merge(style: TextStyle(color: dark ? Colors.white : C.ink), child: child),
        ),
      ),
    );
  }
}

enum Tone { green, amber, red, blue, grey, black }

Color toneFg(Tone t) => switch (t) { Tone.green => C.green, Tone.amber => C.amber, Tone.red => C.red, Tone.blue => C.blue, Tone.grey => C.muted, Tone.black => Colors.white };
Color toneBg(Tone t) => switch (t) { Tone.green => C.greenBg, Tone.amber => C.amberBg, Tone.red => C.redBg, Tone.blue => C.blueBg, Tone.grey => const Color(0xFFEDEFF3), Tone.black => C.black };

/// CMP-06 StatusBadge
class Pill extends StatelessWidget {
  final String text;
  final Tone tone;
  final IconData? icon;
  const Pill(this.text, {super.key, this.tone = Tone.grey, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: toneBg(tone), borderRadius: BorderRadius.circular(R.pill)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: toneFg(tone)), const SizedBox(width: 4)],
          Text(text, style: ts(12, w: FontWeight.w600, c: toneFg(tone))),
        ]),
      );
}

/// CMP-22 ScenarioLabel
class ScenarioTag extends StatelessWidget {
  final bool onDark;
  const ScenarioTag({super.key, this.onDark = false});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
            border: Border.all(color: onDark ? Colors.white54 : C.muted), borderRadius: BorderRadius.circular(R.pill)),
        child: Text('سناریو', style: ts(11, c: onDark ? Colors.white70 : C.muted)),
      );
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined, light, loading;
  const PrimaryButton(this.text, {super.key, this.onPressed, this.icon, this.outlined = false, this.light = false, this.loading = false});
  @override
  Widget build(BuildContext context) {
    final fg = outlined ? C.ink : (light ? C.ink : Colors.white);
    final bg = outlined ? Colors.transparent : (light ? Colors.white : C.black);
    return SizedBox(
      height: 52,
      child: TextButton(
        onPressed: loading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: onPressed == null && !outlined ? C.grey : bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(R.pill),
              side: outlined ? const BorderSide(color: C.ink, width: 1.2) : BorderSide.none),
          padding: const EdgeInsets.symmetric(horizontal: 22),
        ),
        child: loading
            ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[Icon(icon, size: 19), const SizedBox(width: 8)],
                Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: ts(15, w: FontWeight.w700, c: fg))),
              ]),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Row(children: [
          Expanded(child: Text(title, style: ts(16, w: FontWeight.w700))),
          if (action != null) GestureDetector(onTap: onAction, child: Text(action!, style: ts(13, c: C.muted))),
        ]),
      );
}

/// label right, value left on the same baseline
class KV extends StatelessWidget {
  final String k, v;
  final bool bold, dark;
  final Color? vc;
  const KV(this.k, this.v, {super.key, this.bold = false, this.dark = false, this.vc});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Text(k, style: ts(13.5, c: dark ? Colors.white60 : C.muted))),
          Text(v, style: ts(bold ? 15 : 13.5, w: bold ? FontWeight.w800 : FontWeight.w600, c: vc ?? (dark ? Colors.white : C.ink))),
        ]),
      );
}

class Stat extends StatelessWidget {
  final String label, value;
  final bool dark;
  const Stat(this.label, this.value, {super.key, this.dark = false});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value, textAlign: TextAlign.center, style: ts(15, w: FontWeight.w800, c: dark ? Colors.white : C.ink)),
        Text(label, textAlign: TextAlign.center, style: ts(11.5, c: dark ? Colors.white60 : C.muted)),
      ]);
}

class StatRow extends StatelessWidget {
  final List<Stat> items;
  final bool dark;
  const StatRow(this.items, {super.key, this.dark = false});
  @override
  Widget build(BuildContext context) {
    final ch = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) ch.add(Container(width: 1, height: 34, color: dark ? Colors.white24 : C.line));
      ch.add(Expanded(child: items[i]));
    }
    return Row(children: ch);
  }
}

class IconCircle extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  final double size;
  const IconCircle(this.icon, {super.key, this.bg = Colors.white, this.fg = C.ink, this.size = 44});
  @override
  Widget build(BuildContext context) => Container(
      width: size, height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: size * .48));
}

/// CMP-20 GuardrailNotice and general notices
class Notice extends StatelessWidget {
  final String text;
  final Tone tone;
  final IconData icon;
  const Notice(this.text, {super.key, this.tone = Tone.red, this.icon = Icons.gpp_maybe_outlined});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: toneBg(tone), borderRadius: BorderRadius.circular(R.card)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: toneFg(tone), size: 22),
          gap12,
          Expanded(child: Text(text, style: ts(13.5, w: FontWeight.w600, c: toneFg(tone)))),
        ]),
      );
}

class Segmented extends StatelessWidget {
  final List<String> items;
  final int value;
  final ValueChanged<int> onChanged;
  const Segmented({super.key, required this.items, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: C.soft, borderRadius: BorderRadius.circular(R.pill)),
        child: Row(children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: i == value ? C.black : Colors.transparent, borderRadius: BorderRadius.circular(R.pill)),
                  child: Text(items[i], textAlign: TextAlign.center, style: ts(13.5, w: FontWeight.w600, c: i == value ? Colors.white : C.ink)),
                ),
              ),
            ),
        ]),
      );
}

class ChipsRow extends StatelessWidget {
  final List<String> items;
  final int value;
  final ValueChanged<int> onChanged;
  const ChipsRow({super.key, required this.items, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => gap8,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => onChanged(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: i == value ? C.black : Colors.white,
                  border: Border.all(color: i == value ? C.black : C.line),
                  borderRadius: BorderRadius.circular(R.pill)),
              child: Text(items[i], style: ts(13, w: FontWeight.w600, c: i == value ? Colors.white : C.ink)),
            ),
          ),
        ),
      );
}

class Avatar extends StatelessWidget {
  final String name;
  final double size;
  const Avatar(this.name, {super.key, this.size = 42});
  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: size / 2,
        backgroundColor: C.black,
        child: Text(name.isEmpty ? '?' : name.characters.first, style: ts(size * .4, w: FontWeight.w700, c: Colors.white)),
      );
}

void toast(BuildContext c, String msg) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg, style: ts(14, c: Colors.white))));

class EPage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? bottom;
  final List<Widget>? actions;
  const EPage({super.key, required this.title, required this.children, this.bottom, this.actions});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title), actions: actions),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [for (final w in children) Padding(padding: const EdgeInsets.only(bottom: 16), child: w)],
          ),
        ),
        bottomNavigationBar: bottom == null
            ? null
            : SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), child: bottom)),
      );
}
